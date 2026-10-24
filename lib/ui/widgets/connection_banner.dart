import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../state/remote_provider.dart';

/// Bandeau d'état en haut de l'écran : connexion en cours ou dernière erreur.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(remoteProvider.select((s) => s.status));
    final error = ref.watch(remoteProvider.select((s) => s.errorMessage));

    if (status == ConnectionStatus.connecting) {
      return const LinearProgressIndicator(minHeight: 3);
    }
    if (error == null) return const SizedBox.shrink();

    return Material(
      color: AppTheme.errorBgC(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.onErrorBgC(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: AppTheme.onErrorBgC(context)),
              ),
            ),
            IconButton(
              tooltip: 'Fermer',
              color: AppTheme.onErrorBgC(context),
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(remoteProvider.notifier).clearError(),
            ),
          ],
        ),
      ),
    );
  }
}
