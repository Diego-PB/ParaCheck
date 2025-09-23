/*
 SecondaryButton is a customizable outlined button widget.
 It supports an optional background color and a selected state,
 which changes the button’s background, border, foreground colors, and adds a check icon.
 The foreground color automatically adapts for contrast based on the background.
*/

import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String label;                 // Button text label
  final VoidCallback? onPressed;     // Callback for button tap
  final Color? backgroundColor;      // Optional background color override
  final bool selected;               // Whether the button is in a selected state

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Dynamic background color:
    // If no color provided and selected -> use primaryContainer
    final Color? bg = backgroundColor ?? (selected ? scheme.primaryContainer : null);

    // Foreground color logic:
    // - If bg is primaryContainer (default background on selected), use onPrimaryContainer
    // - If bg provided explicitly (e.g., Colors.green), compute white/black based on brightness for contrast
    // - Otherwise, if selected but no background, use primary color
    final Color? fg = bg != null
        ? (backgroundColor == null ? scheme.onPrimaryContainer : _onColor(bg))
        : (selected ? scheme.primary : null);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outline,
          width: selected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            const Icon(Icons.check, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Chooses white or black based on the brightness of the background color
  static Color _onColor(Color bg) {
    return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
