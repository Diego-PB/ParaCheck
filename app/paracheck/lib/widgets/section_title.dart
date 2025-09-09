import 'package:flutter/material.dart';
import '../design/text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

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
