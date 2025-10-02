/*
 TagChip is a simple reusable widget to display a small labeled chip with optional icon.
 It uses a pill-shaped container with padding and a background color from the theme's primaryContainer,
 and text/icon colored with onPrimaryContainer for good contrast.
*/

import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String text;         // Text to display inside the chip
  final IconData? icon;      // Optional icon displayed before the text

  const TagChip(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999), // Pill shape
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: scheme.onPrimaryContainer),
          if (icon != null) const SizedBox(width: 6),
          Text(text, style: TextStyle(color: scheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}
