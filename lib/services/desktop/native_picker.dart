import 'package:fermata/src/rust/api/desktop.dart' as desktop;

class NativePicker {
  const NativePicker();

  Future<String?> pickMusicFolder() => desktop.pickMusicFolder();

  Future<String?> pickBexFile() => desktop.pickBexFile();
}
