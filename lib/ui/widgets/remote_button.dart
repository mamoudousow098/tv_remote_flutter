import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/commands/tv_command.dart';
import '../../core/theme/app_theme.dart';
import '../../state/remote_provider.dart';
import '../../state/settings_provider.dart';

/// Apparence d'un bouton de télécommande.
enum RemoteButtonStyle {
  /// Bouton gris standard.
  normal,

  /// Bouton mis en avant (OK).
  accent,

  /// Bouton rouge marche/arrêt.
  power,

  /// Sans fond (flèches de la croix, +/− des basculeurs).
  ghost,
}

/// Bouton de télécommande lié à une [TvCommand].
///
/// - Grisé automatiquement si la TV courante ne supporte pas la commande.
/// - Retour haptique si activé dans les réglages.
/// - [onPressed] permet de remplacer l'envoi direct (ex. ouvrir le choix de source).
class RemoteButton extends ConsumerWidget {
  const RemoteButton({
    super.key,
    required this.command,
    this.icon,
    this.text,
    this.style = RemoteButtonStyle.normal,
    this.size = 60,
    this.width,
    this.circular = true,
    this.onPressed,
    this.enabled,
  }) : assert(icon != null || text != null, 'icon ou text requis');

  final TvCommand command;
  final IconData? icon;
  final String? text;
  final RemoteButtonStyle style;

  /// Hauteur (et largeur si [width] est null).
  final double size;
  final double? width;
  final bool circular;

  /// Action personnalisée à la place de l'envoi de [command].
  final VoidCallback? onPressed;

  /// Force l'état actif/inactif (sinon : selon les commandes supportées).
  final bool? enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        // Type explicite : sans lui, Dart infère select<bool?> à cause du `??`
    final bool supported =
        enabled ?? ref.watch(remoteProvider.select<bool>((s) => s.supports(command)));

    final (Color bg, Color fg) = switch (style) {
      RemoteButtonStyle.normal => (AppTheme.buttonC(context), AppTheme.onButtonC(context)),
      RemoteButtonStyle.accent => (AppTheme.accentC(context), AppTheme.onAccentC(context)),
      RemoteButtonStyle.power => (AppTheme.powerC(context), AppTheme.onPowerC(context)),
      RemoteButtonStyle.ghost => (Colors.transparent, AppTheme.onButtonC(context)),
    };

    final ShapeBorder shape = circular
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    final Color effectiveFg = supported ? fg : fg.withValues(alpha: 0.35);
    final Color effectiveBg =
        supported || style == RemoteButtonStyle.ghost ? bg : bg.withValues(alpha: 0.5);

    final Widget content = icon != null
        ? Icon(icon, color: effectiveFg, size: size * 0.42)
        : Text(
            text!,
            style: TextStyle(
              color: effectiveFg,
              fontSize: size * 0.3,
              fontWeight: FontWeight.w600,
            ),
          );

    return Semantics(
      button: true,
      enabled: supported,
      label: command.label,
      child: Tooltip(
        message: command.label,
        child: SizedBox(
          width: width ?? size,
          height: size,
          child: Material(
            color: effectiveBg,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: shape,
              onTap: supported ? () => _press(ref) : null,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }

  void _press(WidgetRef ref) {
    if (ref.read(settingsProvider).haptics) {
      HapticFeedback.lightImpact();
    }
    final custom = onPressed;
    if (custom != null) {
      custom();
    } else {
      ref.read(remoteProvider.notifier).send(command);
    }
  }
}
