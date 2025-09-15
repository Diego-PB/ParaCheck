import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/input_field.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/widgets/section_title.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/widgets/stat_tile.dart';
import 'package:paracheck/widgets/tag_chip.dart';
import 'package:paracheck/widgets/app_notice.dart';

class UIKitDemoPage extends StatefulWidget {
  const UIKitDemoPage({super.key});
  @override
  State<UIKitDemoPage> createState() => _UIKitDemoPageState();
}

class _UIKitDemoPageState extends State<UIKitDemoPage> {
  final siteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'UI Kit Demo',
      body: ListView(
        children: [
          const SectionTitle('Boutons'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              PrimaryButton(
                label: 'Valider',
                icon: Icons.check,
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.md),
              SecondaryButton(label: 'Annuler', onPressed: () {}),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          const SectionTitle('Messages'),
          const SizedBox(height: AppSpacing.md),

          // Succès (simple)
          const AppNotice(
            kind: NoticeKind.valid,
            title: 'test',
            message: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
          ),
          const SizedBox(height: AppSpacing.md),

          // Warning (variante bordée)
          const AppNotice(
            kind: NoticeKind.warning,
            title: 'test',
            message: 'Lorem ipsum dolor sit amet consectetur adipiscing elit',
            outlined: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // Attention (variante compacte)
          const AppNotice(
            kind: NoticeKind.attention,
            title: 'test',
            message: 'Lorem ipsum dolor sit amet consectetur adipiscing elit',
            compact: true,
          ),

          const SizedBox(height: AppSpacing.xl),

          const SectionTitle('Champs de texte'),
          const SizedBox(height: AppSpacing.md),
          InputField(controller: siteCtrl, label: 'Site'),

          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Stats'),
          const SizedBox(height: AppSpacing.md),
          const StatTile(
            label: 'Total vols',
            value: '12',
            icon: Icons.flight_takeoff,
          ),

          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Tags'),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.md,
            children: [
              TagChip('MAVIE', icon: Icons.checklist),
              TagChip('SAMI 3'),
              TagChip('Thermique'),
            ],
          ),
        ],
      ),
    );
  }
}
