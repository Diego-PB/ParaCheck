/*
 SectionTitle is a reusable widget to display a section header with a title and optional widget trailing it.
 It uses the custom AppTextStyles.h2 style for the title text,
 and arranges the title and trailing widget horizontally with spacing between.
*/

import 'package:flutter/material.dart';
import '../design/text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;        // Section title text
  final Widget? trailing;    // Optional widget displayed at the end of the row

  const SectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.h2),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
