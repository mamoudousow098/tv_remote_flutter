import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Point d'entrée : ProviderScope rend tous les providers Riverpod disponibles.
void main() {
  runApp(const ProviderScope(child: TvRemoteApp()));
}
