/// Commandes logiques de la télécommande, indépendantes du protocole.
///
/// Chaque contrôleur (IR, Samsung, LG, Roku…) traduit ces commandes dans son
/// propre format : code NEC, touche "KEY_VOLUP", requête ECP "VolumeUp", etc.
/// L'interface ne connaît que cette liste.
enum TvCommand {
  power('Marche/Arrêt'),

  volumeUp('Volume +'),
  volumeDown('Volume −'),
  mute('Muet'),

  channelUp('Chaîne +'),
  channelDown('Chaîne −'),

  digit0('0'),
  digit1('1'),
  digit2('2'),
  digit3('3'),
  digit4('4'),
  digit5('5'),
  digit6('6'),
  digit7('7'),
  digit8('8'),
  digit9('9'),

  up('Haut'),
  down('Bas'),
  left('Gauche'),
  right('Droite'),
  ok('OK'),
  back('Retour'),
  home('Accueil'),
  menu('Menu'),

  /// Fait défiler les sources (touche "Source"/"Input" des télécommandes).
  source('Source'),
  sourceTv('TV'),
  sourceHdmi1('HDMI 1'),
  sourceHdmi2('HDMI 2'),
  sourceHdmi3('HDMI 3'),

  playPause('Lecture/Pause'),
  play('Lecture'),
  pause('Pause'),
  stop('Stop'),
  rewind('Retour rapide'),
  fastForward('Avance rapide');

  const TvCommand(this.label);

  /// Libellé affiché (infobulles, accessibilité, messages d'erreur).
  final String label;

  /// Commande du chiffre [n] (0 à 9).
  static TvCommand digit(int n) {
    if (n < 0 || n > 9) {
      throw ArgumentError.value(n, 'n', 'doit être entre 0 et 9');
    }
    return TvCommand.values.byName('digit$n');
  }

  /// Commandes de choix direct d'une source.
  static const Set<TvCommand> directSources = {
    sourceTv,
    sourceHdmi1,
    sourceHdmi2,
    sourceHdmi3,
  };
}
