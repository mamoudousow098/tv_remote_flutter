import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Réglages de l'application.
/// (Étape 4 : persistance avec shared_preferences, en même temps que la liste des TV.)
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.haptics = true,
  });

  final ThemeMode themeMode;

  /// Vibration courte à chaque appui.
  final bool haptics;

  AppSettings copyWith({ThemeMode? themeMode, bool? haptics}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        haptics: haptics ?? this.haptics,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);

  void setHaptics(bool enabled) => state = state.copyWith(haptics: enabled);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
