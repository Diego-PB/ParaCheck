import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) Icon(icon, size: 18),
      if (icon != null) const SizedBox(width: 8),
      Text(label),
    ]);

    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
