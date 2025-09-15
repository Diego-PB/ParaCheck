import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor; 
  final bool selected;

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

    // Fond dynamique : si pas de couleur fournie et sélectionné -> primaryContainer
    final Color? bg = backgroundColor ?? (selected ? scheme.primaryContainer : null);

    // Couleur du texte/icône (foreground)
    // - si bg vient de primaryContainer -> onPrimaryContainer
    // - si bg est fourni (ex: Colors.green) -> calcul noir/blanc selon contraste
    // - sinon, si sélectionné sans fond -> primary
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

  // Choisit blanc/noir selon la luminosité du fond fourni
  static Color _onColor(Color bg) {
    return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
