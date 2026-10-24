import 'package:flutter/foundation.dart';

import '../commands/tv_command.dart';
import '../models/tv_device.dart';
import 'tv_controller.dart';
import 'tv_exceptions.dart';

/// Contrôleur simulé : permet de tester l'interface sans TV ni émetteur.
///
/// Il journalise chaque commande (visible dans `flutter run` / logcat)
/// et simule un petit temps de réponse réseau.
class DemoController implements TvController {
  DemoController({this.latency = const Duration(milliseconds: 60)});

  final Duration latency;
  bool _disposed = false;

  @override
  final TvDevice device = const TvDevice(
    id: 'demo',
    name: 'TV de démonstration',
    kind: ControllerKind.demo,
  );

  @override
  Set<TvCommand> get supportedCommands => TvCommand.values.toSet();

  @override
  bool get supportsTextInput => true;

  @override
  Future<void> connect() async {
    await Future<void>.delayed(latency);
  }

  @override
  Future<void> send(TvCommand command) async {
    if (_disposed) throw const ConnectionLostException();
    await Future<void>.delayed(latency);
    debugPrint('[Démo] commande envoyée : ${command.name}');
  }

  @override
  Future<void> sendText(String text) async {
    if (_disposed) throw const ConnectionLostException();
    await Future<void>.delayed(latency);
    debugPrint('[Démo] texte envoyé : "$text"');
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}
