import '../commands/tv_command.dart';
import '../models/tv_device.dart';

/// Contrat commun à tous les moyens de piloter une TV.
///
/// Implémentations prévues :
///  - IrController (étape 2) : émetteur IR du téléphone ;
///  - SamsungTizenController, LgWebOsController, AndroidTvController,
///    RokuController, SonyBraviaController, PhilipsController,
///    DialController (étape 4) ;
///  - DemoController (étape 1, tests).
///
/// Toutes les méthodes asynchrones lèvent uniquement des TvException
/// (voir tv_exceptions.dart) : l'interface n'a jamais à connaître
/// SocketException, PlatformException, etc.
abstract interface class TvController {
  /// TV pilotée (nom, plateforme, adresse…).
  TvDevice get device;

  /// Commandes réellement disponibles : l'interface grise les autres.
  Set<TvCommand> get supportedCommands;

  /// Vrai si la TV accepte une saisie de texte (clavier virtuel).
  bool get supportsTextInput;

  /// Établit la connexion (ou vérifie l'émetteur en IR).
  /// Peut déclencher un appairage (popup sur la TV, code PIN).
  Future<void> connect();

  /// Envoie une commande. Lève [UnsupportedCommandException] si elle
  /// n'est pas dans [supportedCommands].
  Future<void> send(TvCommand command);

  /// Envoie du texte (champ de recherche ouvert sur la TV).
  Future<void> sendText(String text);

  /// Ferme les sockets et libère les ressources. Idempotent.
  Future<void> dispose();
}
