/// Type de canal utilisé pour piloter une TV.
enum ControllerKind {
  /// Émetteur infrarouge du téléphone.
  ir,

  /// Protocole réseau (Wi-Fi / Ethernet de la TV).
  network,

  /// Contrôleur simulé (étape 1, tests).
  demo,
}

/// Plateforme logicielle de la TV, détectée à la découverte réseau.
enum TvPlatform {
  samsungTizen('Samsung (Tizen)'),
  lgWebOs('LG (webOS)'),
  androidTv('Android TV / Google TV'),
  roku('Roku'),
  sonyBravia('Sony Bravia'),
  philips('Philips (JointSpace)'),
  dial('Générique (DIAL/UPnP)'),
  unknown('Inconnue');

  const TvPlatform(this.label);
  final String label;
}

/// Une TV mémorisée par l'utilisateur (sérialisable en JSON pour l'étape 4).
///
/// Les secrets (jetons d'appairage, certificats) ne sont PAS stockés ici :
/// ils iront dans flutter_secure_storage, indexés par [id].
class TvDevice {
  const TvDevice({
    required this.id,
    required this.name,
    required this.kind,
    this.platform = TvPlatform.unknown,
    this.host,
    this.port,
    this.irCodeSetId,
  });

  /// Identifiant stable (UUID UPnP, numéro de série, ou "ir:<codeSet>").
  final String id;

  /// Nom affiché ("Salon", "Samsung QE55…").
  final String name;

  final ControllerKind kind;
  final TvPlatform platform;

  /// Adresse IP ou nom d'hôte (mode réseau uniquement).
  final String? host;

  /// Port du protocole de contrôle (mode réseau uniquement).
  final int? port;

  /// Jeu de codes IR retenu par l'assistant (mode IR uniquement).
  final String? irCodeSetId;

  TvDevice copyWith({
    String? name,
    TvPlatform? platform,
    String? host,
    int? port,
    String? irCodeSetId,
  }) {
    return TvDevice(
      id: id,
      name: name ?? this.name,
      kind: kind,
      platform: platform ?? this.platform,
      host: host ?? this.host,
      port: port ?? this.port,
      irCodeSetId: irCodeSetId ?? this.irCodeSetId,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'platform': platform.name,
        'host': host,
        'port': port,
        'irCodeSetId': irCodeSetId,
      };

  /// Lecture tolérante : une valeur inconnue (version future) ne fait pas planter.
  factory TvDevice.fromJson(Map<String, Object?> json) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return TvDevice(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'TV',
      kind: byName(ControllerKind.values, json['kind'], ControllerKind.network),
      platform: byName(TvPlatform.values, json['platform'], TvPlatform.unknown),
      host: json['host'] as String?,
      port: json['port'] as int?,
      irCodeSetId: json['irCodeSetId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) => other is TvDevice && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
