import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String text;
  final IconData? icon;

  const TagChip(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(icon != null) Icon(icon, size: 14, color: scheme.onPrimaryContainer,),
          if(icon != null) const SizedBox(width: 6),
          Text(text, style: TextStyle(color: scheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}
