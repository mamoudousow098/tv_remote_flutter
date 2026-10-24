import '../commands/tv_command.dart';

/// Erreurs métier des contrôleurs.
///
/// `sealed` : le compilateur vérifie qu'un `switch` traite tous les cas.
/// Chaque erreur porte un message prêt à afficher à l'utilisateur.
sealed class TvException implements Exception {
  const TvException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Aucune TV n'est sélectionnée.
class NoControllerException extends TvException {
  const NoControllerException() : super('Aucune TV sélectionnée.');
}

/// La TV ne répond pas à l'adresse connue (éteinte, IP changée, autre réseau).
class TvNotFoundException extends TvException {
  const TvNotFoundException([String? host])
      : super(host == null
            ? 'TV introuvable sur le réseau.'
            : 'TV introuvable à l\'adresse $host.');
}

/// L'utilisateur a refusé l'appairage sur la TV, ou le code PIN est faux.
class PairingRejectedException extends TvException {
  const PairingRejectedException()
      : super('Appairage refusé par la TV. Acceptez la demande affichée sur l\'écran.');
}

/// Le téléphone n'a pas d'émetteur infrarouge.
class NoIrEmitterException extends TvException {
  const NoIrEmitterException()
      : super('Ce téléphone n\'a pas d\'émetteur infrarouge. Utilisez le mode Wi-Fi.');
}

/// La connexion à la TV a été perdue en cours d'utilisation.
class ConnectionLostException extends TvException {
  const ConnectionLostException() : super('Connexion à la TV perdue.');
}

/// Le Wi-Fi est désactivé ou le téléphone n'est pas sur un réseau local.
class WifiDisabledException extends TvException {
  const WifiDisabledException()
      : super('Wi-Fi désactivé. Connectez le téléphone au même réseau que la TV.');
}

/// L'accès au réseau local est bloqué par Android (permission refusée).
class LocalNetworkPermissionException extends TvException {
  const LocalNetworkPermissionException()
      : super('Accès au réseau local refusé. Autorisez-le dans les réglages de l\'application.');
}

/// La plateforme de la TV ne propose pas cette commande.
class UnsupportedCommandException extends TvException {
  UnsupportedCommandException(TvCommand command)
      : super('« ${command.label} » n\'est pas disponible sur cette TV.');
}

/// La TV (ou le mode IR) ne permet pas la saisie de texte.
class TextInputUnsupportedException extends TvException {
  const TextInputUnsupportedException()
      : super('La saisie de texte n\'est pas disponible sur cette TV.');
}

/// La TV n'a pas répondu dans le délai imparti.
class TvTimeoutException extends TvException {
  const TvTimeoutException() : super('La TV ne répond pas (délai dépassé).');
}
