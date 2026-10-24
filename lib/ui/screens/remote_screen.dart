import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/commands/tv_command.dart';
import '../../core/models/tv_device.dart';
import '../../core/platform/device_capabilities.dart';
import '../../core/theme/app_theme.dart';
import '../../state/capabilities_provider.dart';
import '../../state/remote_provider.dart';
import '../../state/settings_provider.dart';
import '../widgets/connection_banner.dart';
import '../widgets/dpad.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/remote_button.dart';
import '../widgets/rocker.dart';
import '../widgets/source_sheet.dart';
import '../widgets/text_input_sheet.dart';

/// Écran principal : la télécommande.
class RemoteScreen extends ConsumerWidget {
  const RemoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(remoteProvider);
    final device = remote.controller?.device;

    // Les erreurs d'envoi s'affichent dans le bandeau ; on log aussi les
    // changements de statut pour le débogage.
    ref.listen(remoteProvider.select((s) => s.status), (previous, next) {
      debugPrint('Statut TV : $previous -> $next');
    });

    return Scaffold(
      appBar: AppBar(
        title: _DeviceTitle(device: device),
        actions: [
          if (remote.supportsTextInput)
            IconButton(
              tooltip: 'Saisie de texte',
              icon: const Icon(Icons.keyboard),
              onPressed: () => showTextInputSheet(context),
            ),
          const _MainMenu(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ConnectionBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Center(
                  // Largeur bornée : rendu correct sur tablette et en paysage
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: const _RemoteLayout(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Disposition des touches, de haut en bas.
class _RemoteLayout extends ConsumerWidget {
  const _RemoteLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anySource = ref.watch(remoteProvider.select((s) =>
        s.supports(TvCommand.source) ||
        TvCommand.directSources.any(s.supports)));

    const gap = SizedBox(height: 24);

    return Column(
      children: [
        // Ligne 1 : marche/arrêt, source, muet
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const RemoteButton(
              command: TvCommand.power,
              icon: Icons.power_settings_new,
              style: RemoteButtonStyle.power,
            ),
            RemoteButton(
              command: TvCommand.source,
              icon: Icons.input,
              enabled: anySource,
              onPressed: () => showSourceSheet(context),
            ),
            const RemoteButton(command: TvCommand.mute, icon: Icons.volume_off),
          ],
        ),
        gap,

        // Croix directionnelle
        const DPad(),
        const SizedBox(height: 16),

        // Retour, Accueil, Menu
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RemoteButton(command: TvCommand.back, icon: Icons.arrow_back),
            RemoteButton(command: TvCommand.home, icon: Icons.home_outlined),
            RemoteButton(command: TvCommand.menu, icon: Icons.menu),
          ],
        ),
        gap,

        // Volume | multimédia | chaînes
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Rocker(
              label: 'VOL',
              upCommand: TvCommand.volumeUp,
              downCommand: TvCommand.volumeDown,
            ),
            _MediaCluster(),
            Rocker(
              label: 'CH',
              upCommand: TvCommand.channelUp,
              downCommand: TvCommand.channelDown,
              upIcon: Icons.keyboard_arrow_up,
              downIcon: Icons.keyboard_arrow_down,
            ),
          ],
        ),
        gap,

        // Pavé numérique repliable (gain de place)
        Material(
          color: AppTheme.panelC(context),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: const ExpansionTile(
            leading: Icon(Icons.dialpad),
            title: Text('Pavé numérique'),
            childrenPadding: EdgeInsets.only(top: 8, bottom: 4),
            children: [NumericKeypad()],
          ),
        ),
      ],
    );
  }
}

/// Bloc multimédia central : retour rapide, lecture/pause, avance rapide, stop.
class _MediaCluster extends StatelessWidget {
  const _MediaCluster();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RemoteButton(
          command: TvCommand.playPause,
          icon: Icons.play_arrow,
          style: RemoteButtonStyle.accent,
          size: 64,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 42 dp : la ligne VOL | multimédia | CH tient sur un écran de 320 dp
            RemoteButton(command: TvCommand.rewind, icon: Icons.fast_rewind, size: 42),
            SizedBox(width: 6),
            RemoteButton(command: TvCommand.stop, icon: Icons.stop, size: 42),
            SizedBox(width: 6),
            RemoteButton(command: TvCommand.fastForward, icon: Icons.fast_forward, size: 42),
          ],
        ),
      ],
    );
  }
}

/// Titre de la barre : nom de la TV + mode (IR / Wi-Fi / démo).
class _DeviceTitle extends StatelessWidget {
  const _DeviceTitle({required this.device});

  final TvDevice? device;

  @override
  Widget build(BuildContext context) {
    final d = device;
    if (d == null) return const Text('Aucune TV');
    final mode = switch (d.kind) {
      ControllerKind.ir => 'Infrarouge',
      ControllerKind.network => 'Wi-Fi · ${d.platform.label}',
      ControllerKind.demo => 'Mode démonstration',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(d.name, overflow: TextOverflow.ellipsis),
        Text(
          mode,
          style: TextStyle(fontSize: 12, color: AppTheme.mutedTextC(context)),
        ),
      ],
    );
  }
}

enum _MenuAction { addTv, theme, haptics, capabilities }

/// Menu ⋮ : ajout de TV (étape 3), thème, vibration, capacités du téléphone.
class _MainMenu extends ConsumerWidget {
  const _MainMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Menu',
      onSelected: (action) => _onSelected(context, ref, action),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _MenuAction.addTv,
          child: ListTile(
            leading: Icon(Icons.add_to_queue),
            title: Text('Ajouter une TV'),
          ),
        ),
        const PopupMenuItem(
          value: _MenuAction.theme,
          child: ListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: Text('Thème'),
          ),
        ),
        CheckedPopupMenuItem(
          value: _MenuAction.haptics,
          checked: settings.haptics,
          child: const Text('Vibration'),
        ),
        const PopupMenuItem(
          value: _MenuAction.capabilities,
          child: ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('Capacités du téléphone'),
          ),
        ),
      ],
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, _MenuAction action) {
    switch (action) {
      case _MenuAction.addTv:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Découverte des TV : disponible à l\'étape 3.')),
        );
      case _MenuAction.theme:
        _showThemeDialog(context, ref);
      case _MenuAction.haptics:
        final notifier = ref.read(settingsProvider.notifier);
        notifier.setHaptics(!ref.read(settingsProvider).haptics);
      case _MenuAction.capabilities:
        showDialog<void>(context: context, builder: (_) => const _CapabilitiesDialog());
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(settingsProvider.select((s) => s.themeMode));
          return SimpleDialog(
            title: const Text('Thème'),
            children: [
              for (final (mode, label) in const [
                (ThemeMode.system, 'Celui du système'),
                (ThemeMode.light, 'Clair'),
                (ThemeMode.dark, 'Sombre'),
              ])
                ListTile(
                  leading: Icon(mode == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
                  title: Text(label),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setThemeMode(mode);
                    Navigator.of(dialogContext).pop();
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Affiche ce que le téléphone sait faire (détecté à l'exécution).
class _CapabilitiesDialog extends ConsumerWidget {
  const _CapabilitiesDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(capabilitiesProvider);
    return AlertDialog(
      title: const Text('Capacités du téléphone'),
      content: switch (caps) {
        AsyncData(:final value) => _CapabilitiesList(caps: value),
        AsyncError(:final error) => Text('Lecture impossible : $error'),
        _ => const SizedBox(
            height: 64,
            child: Center(child: CircularProgressIndicator()),
          ),
      },
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class _CapabilitiesList extends StatelessWidget {
  const _CapabilitiesList({required this.caps});

  final DeviceCapabilities caps;

  @override
  Widget build(BuildContext context) {
    final freqs = caps.carrierRanges.isEmpty
        ? 'non déclarées'
        : caps.carrierRanges.join(', ');
    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(k, style: TextStyle(color: AppTheme.mutedTextC(context))),
              ),
              Expanded(child: Text(v)),
            ],
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line('Appareil', '${caps.manufacturer} ${caps.model}'),
        line('Android (API)', caps.sdkInt == 0 ? 'inconnu' : '${caps.sdkInt}'),
        line('Émetteur IR', caps.hasIrEmitter ? 'oui' : 'non'),
        if (caps.hasIrEmitter) line('Fréquences IR', freqs),
        line('Wi-Fi', caps.hasWifi ? 'oui' : 'non'),
      ],
    );
  }
}
