import 'package:flutter/material.dart';
import '../design/shadows.dart';
import '../design/radius.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const StatTile({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.all(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
