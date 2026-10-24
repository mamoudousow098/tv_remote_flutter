import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/commands/tv_command.dart';
import '../../state/remote_provider.dart';
import '../../state/settings_provider.dart';

/// Ouvre le choix de la source (TV, HDMI 1–3, ou faire défiler).
Future<void> showSourceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _SourceSheet(),
  );
}

class _SourceSheet extends ConsumerWidget {
  const _SourceSheet();

  static const List<(TvCommand, IconData)> _entries = [
    (TvCommand.sourceTv, Icons.live_tv),
    (TvCommand.sourceHdmi1, Icons.settings_input_hdmi),
    (TvCommand.sourceHdmi2, Icons.settings_input_hdmi),
    (TvCommand.sourceHdmi3, Icons.settings_input_hdmi),
    (TvCommand.source, Icons.swap_horiz),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(remoteProvider);
    // Défilant : une bottom sheet est limitée à 9/16 de l'écran
    // (paysage, petits écrans) et les 5 sources peuvent ne pas tenir.
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Choisir la source', style: TextStyle(fontSize: 18)),
          ),
          for (final (command, icon) in _entries)
            ListTile(
              leading: Icon(icon),
              title: Text(command == TvCommand.source
                  ? 'Source suivante'
                  : command.label),
              subtitle: remote.supports(command)
                  ? null
                  : const Text('Non disponible sur cette TV'),
              enabled: remote.supports(command),
              onTap: () {
                if (ref.read(settingsProvider).haptics) {
                  HapticFeedback.selectionClick();
                }
                ref.read(remoteProvider.notifier).send(command);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ));
  }
}
