import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_remote/core/commands/tv_command.dart';
import 'package:tv_remote/core/controllers/tv_controller.dart';
import 'package:tv_remote/core/controllers/tv_exceptions.dart';
import 'package:tv_remote/core/models/tv_device.dart';
import 'package:tv_remote/state/remote_provider.dart';

/// Contrôleur factice configurable pour tester les branches d'erreur.
class FakeController implements TvController {
  FakeController({
    this.supported = const {TvCommand.power, TvCommand.volumeUp},
    this.failWith,
    this.connectError,
  });

  final Set<TvCommand> supported;
  final TvException? failWith;
  final TvException? connectError;
  final List<TvCommand> sent = [];
  bool disposed = false;

  @override
  TvDevice get device =>
      const TvDevice(id: 'fake', name: 'Fake', kind: ControllerKind.network);

  @override
  Set<TvCommand> get supportedCommands => supported;

  @override
  bool get supportsTextInput => false;

  @override
  Future<void> connect() async {
    final e = connectError;
    if (e != null) throw e;
  }

  @override
  Future<void> send(TvCommand command) async {
    final e = failWith;
    if (e != null) throw e;
    sent.add(command);
  }

  @override
  Future<void> sendText(String text) async {}

  @override
  Future<void> dispose() async => disposed = true;
}

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  RemoteNotifier notifier() => container.read(remoteProvider.notifier);
  RemoteState state() => container.read(remoteProvider);

  test('démarre sur le contrôleur de démonstration, connecté', () {
    expect(state().status, ConnectionStatus.connected);
    expect(state().controller?.device.kind, ControllerKind.demo);
  });

  test('switchTo connecte le nouveau contrôleur et libère l\'ancien', () async {
    final first = FakeController();
    final second = FakeController();
    await notifier().switchTo(first);
    await notifier().switchTo(second);

    expect(first.disposed, isTrue);
    expect(state().controller, same(second));
    expect(state().status, ConnectionStatus.connected);
  });

  test('appairage refusé : statut error + message', () async {
    await notifier().switchTo(
      FakeController(connectError: const PairingRejectedException()),
    );
    expect(state().status, ConnectionStatus.error);
    expect(state().errorMessage, contains('Appairage refusé'));
  });

  test('commande non supportée : refusée sans appeler le contrôleur', () async {
    final fake = FakeController();
    await notifier().switchTo(fake);

    final ok = await notifier().send(TvCommand.mute);

    expect(ok, isFalse);
    expect(fake.sent, isEmpty);
    expect(state().errorMessage, contains('Muet'));
    expect(state().status, ConnectionStatus.connected); // pas une perte de connexion
  });

  test('perte de connexion : statut error', () async {
    await notifier().switchTo(
      FakeController(failWith: const ConnectionLostException()),
    );
    final ok = await notifier().send(TvCommand.power);

    expect(ok, isFalse);
    expect(state().status, ConnectionStatus.error);
  });

  test('envoi réussi : lastCommand mis à jour et erreur effacée', () async {
    final fake = FakeController();
    await notifier().switchTo(fake);
    await notifier().send(TvCommand.mute); // provoque une erreur
    await notifier().send(TvCommand.volumeUp);

    expect(fake.sent, [TvCommand.volumeUp]);
    expect(state().lastCommand, TvCommand.volumeUp);
    expect(state().errorMessage, isNull);
  });

  test('saisie de texte non supportée : message dédié', () async {
    await notifier().switchTo(FakeController());
    final ok = await notifier().sendText('bonjour');
    expect(ok, isFalse);
    expect(state().errorMessage, contains('saisie de texte'));
  });

  test('TvDevice : aller-retour JSON tolérant', () {
    const d = TvDevice(
      id: 'uuid:1',
      name: 'Salon',
      kind: ControllerKind.network,
      platform: TvPlatform.roku,
      host: '192.168.1.20',
      port: 8060,
    );
    final back = TvDevice.fromJson(d.toJson());
    expect(back.platform, TvPlatform.roku);
    expect(back.port, 8060);

    final unknown = TvDevice.fromJson({'id': 'x', 'platform': 'futureTv'});
    expect(unknown.platform, TvPlatform.unknown);
  });
}
