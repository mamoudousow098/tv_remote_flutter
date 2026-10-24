import 'package:flutter/material.dart';

import '../../core/commands/tv_command.dart';
import '../../core/theme/app_theme.dart';
import 'remote_button.dart';

/// Croix directionnelle circulaire avec OK au centre.
class DPad extends StatelessWidget {
  const DPad({super.key, this.diameter = 220});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final arrow = diameter * 0.27;
    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.dpadC(context),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: RemoteButton(
                command: TvCommand.up,
                icon: Icons.keyboard_arrow_up,
                style: RemoteButtonStyle.ghost,
                size: arrow,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: RemoteButton(
                command: TvCommand.down,
                icon: Icons.keyboard_arrow_down,
                style: RemoteButtonStyle.ghost,
                size: arrow,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: RemoteButton(
                command: TvCommand.left,
                icon: Icons.keyboard_arrow_left,
                style: RemoteButtonStyle.ghost,
                size: arrow,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RemoteButton(
                command: TvCommand.right,
                icon: Icons.keyboard_arrow_right,
                style: RemoteButtonStyle.ghost,
                size: arrow,
              ),
            ),
            Center(
              child: RemoteButton(
                command: TvCommand.ok,
                text: 'OK',
                style: RemoteButtonStyle.accent,
                size: diameter * 0.36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
