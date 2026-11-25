import 'package:fermata/core/di/service_locator.dart';
import 'package:fermata/src/rust/api/plugin/plugin_info.dart';
import 'package:flutter/material.dart';

class PluginManagerScreen extends StatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  State<PluginManagerScreen> createState() => _PluginManagerScreenState();
}

class _PluginManagerScreenState extends State<PluginManagerScreen> {
  List<PluginInfo> plugins = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final value = await ServiceLocator.plugins?.available();
    if (mounted) setState(() => plugins = value ?? []);
  }

  Future<void> _install() async {
    try {
      final path = await ServiceLocator.nativePicker.pickBexFile();
      if (path != null && path.isNotEmpty) {
        await ServiceLocator.plugins?.install(path);
        await _refresh();
      }
    } catch (failure) {
      if (mounted) setState(() => error = failure.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugins'),
        actions: [
          IconButton(
            tooltip: 'Install plugin',
            onPressed: _install,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          if (error != null) Text(error!),
          Expanded(
            child: ListView(
              children: [
                for (final plugin in plugins)
                  ListTile(
                    title: Text(plugin.manifest.name),
                    subtitle: Text(plugin.manifest.id),
                    trailing: IconButton(
                      tooltip: 'Delete plugin',
                      onPressed: () async {
                        await ServiceLocator.plugins?.delete(plugin);
                        await _refresh();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
