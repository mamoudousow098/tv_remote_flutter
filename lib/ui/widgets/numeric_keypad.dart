import 'package:flutter/material.dart';

import '../../core/commands/tv_command.dart';
import 'remote_button.dart';

/// Pavé numérique 0–9 (grille 3×4, le 0 centré en bas).
///
/// Construit avec des Row/Column (et non un GridView) : il vit dans un
/// SingleChildScrollView vertical, une grille défilante imbriquée poserait
/// des problèmes de contraintes.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key});

  static const double _key = 64;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    Widget digit(int n) => RemoteButton(
          command: TvCommand.digit(n),
          text: '$n',
          size: _key,
        );

    Widget row(List<Widget> keys) => Padding(
          padding: const EdgeInsets.only(bottom: _gap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < keys.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                keys[i],
              ],
            ],
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([digit(1), digit(2), digit(3)]),
        row([digit(4), digit(5), digit(6)]),
        row([digit(7), digit(8), digit(9)]),
        row([
          const SizedBox(width: _key, height: _key),
          digit(0),
          const SizedBox(width: _key, height: _key),
        ]),
      ],
    );
  }
}
