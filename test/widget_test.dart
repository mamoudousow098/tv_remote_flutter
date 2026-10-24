import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_remote/app.dart';
import 'package:tv_remote/core/commands/tv_command.dart';
import 'package:tv_remote/state/remote_provider.dart';

// Remplace le widget_test.dart généré par `flutter create` (qui référence MyApp).
void main() {
  testWidgets('la télécommande s\'affiche et envoie une commande', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TvRemoteApp()));
    await tester.pumpAndSettle();

    expect(find.text('TV de démonstration'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.byTooltip(TvCommand.power.label));
    // Le contrôleur de démo répond après 60 ms
    await tester.pump(const Duration(milliseconds: 100));

    final element = tester.element(find.byType(TvRemoteApp));
    final container = ProviderScope.containerOf(element);
    expect(container.read(remoteProvider).lastCommand, TvCommand.power);
  });

  testWidgets('le choix de source s\'ouvre', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TvRemoteApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(TvCommand.source.label));
    await tester.pumpAndSettle();

    expect(find.text('Choisir la source'), findsOneWidget);
    expect(find.text('HDMI 1'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
