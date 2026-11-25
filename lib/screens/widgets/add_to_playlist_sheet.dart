// ignore_for_file: deprecated_member_use

import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:flutter/material.dart';

Future<int?> showAddToPlaylistSheet(
  BuildContext context, {
  required PlaylistsCubit playlists,
  required Track track,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddToPlaylistSheet(playlists: playlists, track: track),
  );
}

class AddToPlaylistSheet extends StatefulWidget {
  const AddToPlaylistSheet({
    super.key,
    required this.playlists,
    required this.track,
  });

  final PlaylistsCubit playlists;
  final Track track;

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  final TextEditingController _name = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _createAndAdd() async {
    final name = _name.text.trim();
    if (name.isEmpty || _creating) return;
    setState(() => _creating = true);
    final id = await widget.playlists.createPlaylist(name);
    if (!mounted) return;
    setState(() => _creating = false);
    if (id != null) {
      Navigator.of(context).pop(id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create that playlist.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: StreamBuilder<PlaylistsState>(
          stream: widget.playlists.stream,
          initialData: widget.playlists.state,
          builder: (context, snapshot) {
            final state = snapshot.data ?? widget.playlists.state;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add to playlist',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Flexible(
                  child: state.playlists.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No playlists yet. Create one below.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = state.playlists[index];
                            return ListTile(
                              leading: const Icon(Icons.playlist_play),
                              title: Text(playlist.title),
                              trailing: playlist.isPinned
                                  ? const Icon(Icons.push_pin, size: 18)
                                  : null,
                              onTap: () =>
                                  Navigator.of(context).pop(playlist.id),
                            );
                          },
                        ),
                ),
                const Divider(height: 24),
                TextField(
                  controller: _name,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _createAndAdd(),
                  decoration: const InputDecoration(
                    labelText: 'New playlist',
                    prefixIcon: Icon(Icons.add),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _creating ? null : _createAndAdd,
                  icon: _creating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.playlist_add),
                  label: const Text('Create & add'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
