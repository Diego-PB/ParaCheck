/*
 PrimaryButton is a customizable elevated button widget.
 It displays a label with an optional icon positioned before the text,
 with adjustable size controlling the icon and text font size.
 This button uses minimal styling by default and is intended as a primary call-to-action.
*/

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;           // Button text label
  final VoidCallback? onPressed; // Callback triggered on button press
  final IconData? icon;          // Optional icon displayed before the label
  final double? size;            // Font and icon size (default 16)

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSize = size ?? 16;
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) Icon(icon, size: effectiveSize),
      if (icon != null) const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(fontSize: effectiveSize),
      ),
    ]);

    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
