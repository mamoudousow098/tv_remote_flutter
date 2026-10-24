import 'package:flutter/material.dart';

import '../../core/commands/tv_command.dart';
import '../../core/theme/app_theme.dart';
import 'remote_button.dart';

/// Basculeur vertical +/− (volume, chaînes), comme sur une télécommande physique.
class Rocker extends StatelessWidget {
  const Rocker({
    super.key,
    required this.label,
    required this.upCommand,
    required this.downCommand,
    this.upIcon = Icons.add,
    this.downIcon = Icons.remove,
  });

  final String label;
  final TvCommand upCommand;
  final TvCommand downCommand;
  final IconData upIcon;
  final IconData downIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.buttonC(context),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RemoteButton(
            command: upCommand,
            icon: upIcon,
            style: RemoteButtonStyle.ghost,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.mutedTextC(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          RemoteButton(
            command: downCommand,
            icon: downIcon,
            style: RemoteButtonStyle.ghost,
            size: 60,
          ),
        ],
      ),
    );
  }
}
