import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/commands/tv_command.dart';
import '../core/controllers/demo_controller.dart';
import '../core/controllers/tv_controller.dart';
import '../core/controllers/tv_exceptions.dart';

/// État de la connexion avec la TV courante.
enum ConnectionStatus { disconnected, connecting, connected, error }

@immutable
class RemoteState {
  const RemoteState({
    this.controller,
    this.status = ConnectionStatus.disconnected,
    this.errorMessage,
    this.lastCommand,
  });

  final TvController? controller;
  final ConnectionStatus status;

  /// Message de la dernière erreur, à afficher (null = rien à signaler).
  final String? errorMessage;

  /// Dernière commande envoyée avec succès (retour visuel).
  final TvCommand? lastCommand;

  bool supports(TvCommand command) =>
      controller?.supportedCommands.contains(command) ?? false;

  bool get supportsTextInput => controller?.supportsTextInput ?? false;

  RemoteState copyWith({
    ConnectionStatus? status,
    String? errorMessage,
    bool clearError = false,
    TvCommand? lastCommand,
  }) {
    return RemoteState(
      controller: controller,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastCommand: lastCommand ?? this.lastCommand,
    );
  }
}

/// Orchestration : quel contrôleur est actif, envoi des commandes, erreurs.
///
/// L'interface n'appelle jamais un contrôleur directement : tout passe par
/// ce Notifier, qui transforme les TvException en état affichable.
class RemoteNotifier extends Notifier<RemoteState> {
  TvController? _active;

  @override
  RemoteState build() {
    // Étape 1 : contrôleur simulé. À l'étape 4, on restaurera la dernière TV utilisée.
    final demo = DemoController();
    _active = demo;
    ref.onDispose(() {
      _active?.dispose();
      _active = null;
    });
    return RemoteState(controller: demo, status: ConnectionStatus.connected);
  }

  /// Bascule vers un autre contrôleur (autre TV, ou passage IR <-> Wi-Fi).
  Future<void> switchTo(TvController next) async {
    final previous = _active;
    _active = next;
    state = RemoteState(controller: next, status: ConnectionStatus.connecting);
    await previous?.dispose();
    try {
      await next.connect();
      if (!ref.mounted || _active != next) return; // un autre switch a eu lieu entre-temps
      state = state.copyWith(status: ConnectionStatus.connected, clearError: true);
    } on TvException catch (e) {
      if (!ref.mounted || _active != next) return;
      state = state.copyWith(status: ConnectionStatus.error, errorMessage: e.message);
    }
  }

  /// Envoie une commande. Renvoie true si elle est partie.
  Future<bool> send(TvCommand command) async {
    final controller = _active;
    if (controller == null) {
      _fail(const NoControllerException());
      return false;
    }
    if (!controller.supportedCommands.contains(command)) {
      _fail(UnsupportedCommandException(command));
      return false;
    }
    try {
      await controller.send(command);
      if (!ref.mounted || _active != controller) return true;
      state = state.copyWith(
        status: ConnectionStatus.connected,
        lastCommand: command,
        clearError: true,
      );
      return true;
    } on TvException catch (e) {
      _fail(e);
      return false;
    }
  }

  /// Envoie du texte vers la TV (champ de recherche).
  Future<bool> sendText(String text) async {
    final controller = _active;
    if (controller == null) {
      _fail(const NoControllerException());
      return false;
    }
    if (!controller.supportsTextInput) {
      _fail(const TextInputUnsupportedException());
      return false;
    }
    try {
      await controller.sendText(text);
      if (ref.mounted && _active == controller) {
        state = state.copyWith(clearError: true);
      }
      return true;
    } on TvException catch (e) {
      _fail(e);
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  void _fail(TvException e) {
    if (!ref.mounted) return;
    // Une perte de connexion change le statut ; une commande non supportée non.
    final status = switch (e) {
      ConnectionLostException() ||
      TvNotFoundException() ||
      WifiDisabledException() ||
      LocalNetworkPermissionException() ||
      TvTimeoutException() =>
        ConnectionStatus.error,
      _ => state.status,
    };
    state = state.copyWith(status: status, errorMessage: e.message);
  }
}

final remoteProvider =
    NotifierProvider<RemoteNotifier, RemoteState>(RemoteNotifier.new);
