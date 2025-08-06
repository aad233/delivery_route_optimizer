import 'package:flutter/material.dart';
import '../utils/extensions.dart';

class TimeBadge extends StatelessWidget {
  final DateTime? time;
  final bool isAsap;
  final bool compact;

  const TimeBadge({
    super.key,
    this.time,
    this.isAsap = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAsap
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAsap ? 'ASAP' : time?.toTimeString() ?? '--:--',
        style: theme.textTheme.labelLarge?.copyWith(
          color: isAsap
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
