import 'package:flutter/material.dart';

/// Thème de l'application.
///
/// Règle : aucun widget n'utilise de couleur statique. Toutes les couleurs
/// passent par les helpers contextuels `xxxC(context)`, qui lisent le
/// ColorScheme courant : le thème sombre fonctionne donc partout sans effort.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF1565C0);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );
  }

  static ColorScheme _s(BuildContext c) => Theme.of(c).colorScheme;

  // --- Fonds ---
  static Color backgroundC(BuildContext c) => _s(c).surface;
  static Color panelC(BuildContext c) => _s(c).surfaceContainerLow;

  // --- Boutons standards ---
  static Color buttonC(BuildContext c) => _s(c).surfaceContainerHigh;
  static Color onButtonC(BuildContext c) => _s(c).onSurface;

  // --- Bouton principal (OK, actions mises en avant) ---
  static Color accentC(BuildContext c) => _s(c).primary;
  static Color onAccentC(BuildContext c) => _s(c).onPrimary;

  // --- Bouton marche/arrêt ---
  static Color powerC(BuildContext c) => _s(c).error;
  static Color onPowerC(BuildContext c) => _s(c).onError;

  // --- Croix directionnelle ---
  static Color dpadC(BuildContext c) => _s(c).surfaceContainerHighest;

  // --- Textes secondaires ---
  static Color mutedTextC(BuildContext c) => _s(c).onSurfaceVariant;

  // --- Bandeaux d'état ---
  static Color errorBgC(BuildContext c) => _s(c).errorContainer;
  static Color onErrorBgC(BuildContext c) => _s(c).onErrorContainer;
  static Color infoBgC(BuildContext c) => _s(c).secondaryContainer;
  static Color onInfoBgC(BuildContext c) => _s(c).onSecondaryContainer;
}
