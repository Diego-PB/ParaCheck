import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? size;

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
          borderRadius: BorderRadius.circular(32), // Plus arrondi
        ),
        textStyle: TextStyle(fontSize: effectiveSize),
        elevation: 2,
      ),
      child: child,
    );
  }
}