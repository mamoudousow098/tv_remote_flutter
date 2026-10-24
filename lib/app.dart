import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'state/settings_provider.dart';
import 'ui/screens/remote_screen.dart';

/// Racine de l'application : thème clair/sombre piloté par les réglages.
class TvRemoteApp extends ConsumerWidget {
  const TvRemoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: 'Télécommande',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const RemoteScreen(),
    );
  }
}
