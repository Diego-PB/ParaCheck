import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? size;

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