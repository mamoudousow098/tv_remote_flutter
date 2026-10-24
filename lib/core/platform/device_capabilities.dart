import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plage de fréquences porteuses supportée par l'émetteur IR (en Hz).
@immutable
class CarrierRange {
  const CarrierRange(this.minHz, this.maxHz);

  final int minHz;
  final int maxHz;

  bool contains(int hz) => hz >= minHz && hz <= maxHz;

  @override
  String toString() => minHz == maxHz ? '$minHz Hz' : '$minHz–$maxHz Hz';
}

/// Capacités matérielles du téléphone, lues à l'exécution.
///
/// Rien n'est supposé : un téléphone sans IR, sans Wi-Fi, ou dont le
/// fabricant a mal implémenté l'API renvoie simplement des valeurs "absentes".
@immutable
class DeviceCapabilities {
  const DeviceCapabilities({
    required this.hasIrEmitter,
    required this.carrierRanges,
    required this.hasWifi,
    required this.sdkInt,
    required this.manufacturer,
    required this.model,
  });

  /// Valeur de repli si le canal natif est indisponible (tests, erreur).
  const DeviceCapabilities.unknown()
      : hasIrEmitter = false,
        carrierRanges = const [],
        hasWifi = true,
        sdkInt = 0,
        manufacturer = '?',
        model = '?';

  final bool hasIrEmitter;

  /// Vide si l'émetteur ne déclare pas ses fréquences (cas fréquent).
  final List<CarrierRange> carrierRanges;

  final bool hasWifi;

  /// Build.VERSION.SDK_INT (24 = Android 7.0, 33 = 13, 36 = 16, 37 = 17).
  final int sdkInt;

  final String manufacturer;
  final String model;

  factory DeviceCapabilities.fromMap(Map<Object?, Object?> map) {
    final ranges = <CarrierRange>[];
    final raw = map['carrierFrequencies'];
    if (raw is List) {
      for (final r in raw) {
        if (r is List && r.length == 2 && r[0] is int && r[1] is int) {
          ranges.add(CarrierRange(r[0] as int, r[1] as int));
        }
      }
    }
    return DeviceCapabilities(
      hasIrEmitter: map['hasIrEmitter'] == true,
      carrierRanges: List.unmodifiable(ranges),
      hasWifi: map['hasWifi'] != false,
      sdkInt: (map['sdkInt'] as int?) ?? 0,
      manufacturer: (map['manufacturer'] as String?) ?? '?',
      model: (map['model'] as String?) ?? '?',
    );
  }
}

/// Lecture des capacités via le MethodChannel natif (MainActivity.kt).
class CapabilitiesChannel {
  const CapabilitiesChannel();

  static const MethodChannel _channel = MethodChannel('tv_remote/capabilities');

  /// Ne lève jamais d'exception : en cas de problème, renvoie [DeviceCapabilities.unknown].
  Future<DeviceCapabilities> read() async {
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>('getCapabilities');
      if (map == null) return const DeviceCapabilities.unknown();
      return DeviceCapabilities.fromMap(map);
    } on PlatformException catch (e) {
      debugPrint('Capacités : erreur native ${e.code} ${e.message}');
      return const DeviceCapabilities.unknown();
    } on MissingPluginException {
      // Tests unitaires, ou plateforme autre qu'Android
      return const DeviceCapabilities.unknown();
    }
  }
}
