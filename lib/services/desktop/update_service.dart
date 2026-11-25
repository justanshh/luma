import 'dart:convert';
import 'dart:io';

class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UpdateService {
  const UpdateService();

  static const repository = 'justanshh/luma';
  static const productName = 'Luma';
  static const currentVersion = '0.1.0';
  static const rpmInstallTarget = '/usr/lib64/luma/luma';

  static String? _lastError;

  /// Details of the most recent update failure, or `null` after success.
  String? get lastError => _lastError;

  Future<String?> downloadUpdate() async {
    _lastError = null;
    final client = HttpClient();
    Directory? tempDirectory;
    try {
      final request = await client.getUrl(Uri.parse(
          'https://api.github.com/repos/$repository/releases/latest'));
      request.headers
          .set(HttpHeaders.userAgentHeader, '$productName/$currentVersion');
      request.headers
          .set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'GitHub release request failed (${response.statusCode} '
                  '${response.reasonPhrase})'
              .trim(),
        );
      }

      final decoded = jsonDecode(await utf8.decoder.bind(response).join());
      if (decoded is! Map<String, dynamic>) {
        throw const UpdateException('GitHub returned invalid release data.');
      }
      final release = decoded;
      final tag = release['tag_name']?.toString() ?? '';
      if (tag.isEmpty) {
        throw const UpdateException(
            'The latest GitHub release has no version tag.');
      }
      if (tag.replaceFirst('v', '') == currentVersion) return null;

      final assets = release['assets'] as List<dynamic>? ?? const [];
      Map<String, dynamic>? asset;
      for (final item in assets) {
        if (item is Map<String, dynamic> &&
            (item['name']?.toString().endsWith('x86_64.AppImage') ?? false)) {
          asset = item;
          break;
        }
      }
      final url = asset?['browser_download_url']?.toString();
      final downloadUri = url == null ? null : Uri.tryParse(url);
      if (downloadUri == null ||
          downloadUri.scheme != 'https' ||
          downloadUri.host.isEmpty) {
        throw const UpdateException(
          'The latest release does not contain a valid x86_64 AppImage download.',
        );
      }

      tempDirectory = await Directory.systemTemp
          .createTemp('${productName.toLowerCase()}-update-');
      final temp = File(
        '${tempDirectory.path}${Platform.pathSeparator}$productName-x86_64.AppImage',
      );
      final download = await client.getUrl(downloadUri);
      download.headers
          .set(HttpHeaders.userAgentHeader, '$productName/$currentVersion');
      final stream = await download.close();
      if (stream.statusCode != HttpStatus.ok) {
        throw HttpException(
          'AppImage download failed (${stream.statusCode} '
                  '${stream.reasonPhrase})'
              .trim(),
        );
      }

      await stream.pipe(temp.openWrite());
      await _validateUpdateFile(temp, requireExecutable: false);
      final chmod = await Process.run('chmod', ['0755', temp.path]);
      if (chmod.exitCode != 0) {
        throw UpdateException(
          'Could not make the downloaded AppImage executable: '
          '${_processDetail(chmod)}',
        );
      }
      await _validateUpdateFile(temp);
      return temp.path;
    } catch (error) {
      _lastError = error.toString();
      if (tempDirectory != null) await _deleteDirectory(tempDirectory);
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> installUpdate(String path) async {
    _lastError = null;
    String? target;
    try {
      if (!Platform.isLinux) {
        throw const UpdateException('Updates are only supported on Linux.');
      }
      await _validateUpdateFile(File(path));
      target = _resolveInstallTarget();
      if (!target.startsWith('/')) {
        throw const UpdateException(
          'The installation target must be an absolute path.',
        );
      }

      // Stage beside the destination so the final rename is atomic, including
      // when replacing the AppImage that is currently running.
      final result = await Process.run('pkexec', [
        '/bin/sh',
        '-c',
        _atomicInstallScript,
        '$productName-update',
        path,
        target,
      ]);
      if (result.exitCode != 0) {
        throw UpdateException(_processFailure(result));
      }

      if (File(path).absolute.path != File(target).absolute.path) {
        await _cleanupDownloadedFile(path);
      }
      return true;
    } catch (error) {
      _lastError = error.toString();
      if (target == null ||
          File(path).absolute.path != File(target).absolute.path) {
        await _cleanupDownloadedFile(path);
      }
      return false;
    }
  }

  String _resolveInstallTarget() {
    final appImage = Platform.environment['APPIMAGE'];
    if (appImage != null && appImage.isNotEmpty) return appImage;

    // RPM installs may use either the Luma layout or the legacy layout while
    // the packaged executable is running. Replacing that path keeps its
    // launcher and desktop integration intact.
    final executable = Platform.resolvedExecutable;
    const rpmRoots = [
      '/usr/lib64/luma/',
      '/usr/lib64/fermata/',
      '/usr/lib/luma/',
      '/usr/lib/fermata/',
    ];
    for (final root in rpmRoots) {
      if (executable.startsWith(root)) return executable;
    }
    return rpmInstallTarget;
  }

  Future<void> _validateUpdateFile(
    File file, {
    bool requireExecutable = true,
  }) async {
    final stat = await file.stat();
    if (stat.type == FileSystemEntityType.notFound) {
      throw UpdateException('Update file not found: ${file.path}');
    }
    if (stat.type != FileSystemEntityType.file) {
      throw UpdateException('Update is not a regular file: ${file.path}');
    }
    if (stat.size <= 0) {
      throw UpdateException('Downloaded AppImage is empty: ${file.path}');
    }
    // Any execute bit is sufficient here; the installed copy is always 0755.
    if (requireExecutable && (stat.mode & 0x49) == 0) {
      throw UpdateException('Update file is not executable: ${file.path}');
    }
  }

  Future<void> _cleanupDownloadedFile(String path) async {
    final file = File(path).absolute;
    final directory = file.parent;
    final name = directory.path.split(Platform.pathSeparator).last;
    if (directory.parent.path != Directory.systemTemp.absolute.path ||
        !name.startsWith('${productName.toLowerCase()}-update-')) {
      return;
    }
    await _deleteDirectory(directory);
  }

  Future<void> _deleteDirectory(Directory directory) async {
    try {
      await directory.delete(recursive: true);
    } on FileSystemException catch (_) {
      // Cleanup is best effort and must not mask the original update error.
      return;
    }
  }

  String _processDetail(ProcessResult result) {
    final stderr = result.stderr.toString().trim();
    final stdout = result.stdout.toString().trim();
    var detail = stderr.isNotEmpty ? stderr : stdout;
    if (detail.length > 1000) detail = '${detail.substring(0, 1000)}…';
    return detail.isEmpty ? 'exit code ${result.exitCode}' : detail;
  }

  String _processFailure(ProcessResult result) {
    final authorizationHint = switch (result.exitCode) {
      126 => 'The authentication dialog could not be opened.',
      127 => 'Authentication was cancelled or permission was denied.',
      _ => null,
    };
    return [
      'Update installation failed (pkexec exit code ${result.exitCode}).',
      _processDetail(result),
      if (authorizationHint != null) authorizationHint,
    ].join(' ');
  }

  static const _atomicInstallScript = r'''
set -eu
source=$1
target=$2
target_dir=${target%/*}
[ -n "$target_dir" ] || target_dir=/
staged=''
cleanup() {
  [ -z "$staged" ] || rm -f -- "$staged"
}
trap cleanup 0
trap 'exit 1' 1 2 15
staged=$(mktemp "$target_dir/.luma-update.XXXXXX")
install -m 0755 -- "$source" "$staged"
mv -fT -- "$staged" "$target"
staged=''
''';
}
