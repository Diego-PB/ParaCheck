/*
 HomeButton is a reusable custom button widget designed.
 It displays a label with an optional icon, with adjustable size for both text and icon,
 styled as a rounded elevated button with generous padding and slight elevation.
*/

import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String label;           // Text label on the button
  final VoidCallback? onPressed; // Callback when the button is pressed
  final IconData? icon;          // Optional icon displayed before the label
  final double? size;            // Size for icon and text font (default 40)

  const HomeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSize = size ?? 40;
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) Icon(icon, size: effectiveSize),
      if (icon != null) const SizedBox(width: 10),
      Text(
        label,
        style: TextStyle(fontSize: effectiveSize, fontWeight: FontWeight.bold),
      ),
    ]);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // More rounded corners
        ),
        textStyle: TextStyle(fontSize: effectiveSize),
        elevation: 2,
      ),
      child: child,
    );
  }
}
