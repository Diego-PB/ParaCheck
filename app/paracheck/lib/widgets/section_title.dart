/*
 SectionTitle: titre + optionnel trailing, sans overflow
*/
import 'package:flutter/material.dart';
import '../design/text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Le texte occupe l'espace dispo et ne déborde pas.
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2,
            maxLines: 2,                // ajuste à 1/2/3 selon ton design
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          // Le trailing reste à droite et peut se tasser si l’espace manque.
          Flexible(
            fit: FlexFit.loose,
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing!,
            ),
          ),
        ],
      ],
    );
  }
}
