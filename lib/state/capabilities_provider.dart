import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/platform/device_capabilities.dart';

/// Capacités du téléphone, lues une seule fois au démarrage.
class CapabilitiesNotifier extends AsyncNotifier<DeviceCapabilities> {
  @override
  Future<DeviceCapabilities> build() => const CapabilitiesChannel().read();
}

final capabilitiesProvider =
    AsyncNotifierProvider<CapabilitiesNotifier, DeviceCapabilities>(
  CapabilitiesNotifier.new,
);
