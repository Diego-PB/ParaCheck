import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor; // ✅ nouvelle propriété

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: backgroundColor, // ✅ appliqué ici
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: backgroundColor != null
              ? Colors.white // ✅ texte blanc si fond coloré
              : null,
        ),
      ),
    );
  }
}
