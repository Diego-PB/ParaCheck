import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/design/spacing.dart';
import '../widgets/section_title.dart';
import '../widgets/app_notice.dart';
import '../widgets/primary_button.dart';

class ConditionVolPage extends StatefulWidget {
  const ConditionVolPage({super.key});

  @override
  State<ConditionVolPage> createState() => _ConditionVolPageState();
}

class _ConditionVolPageState extends State<ConditionVolPage> {
  int? selectedLevel;

  final conditions = [
    {'level': 1, 'label': 'Conditions calmes '},
    {'level': 2, 'label': 'Turbulences moyennes et localisées '},
    {'level': 3, 'label': 'Turbulences fortes et fréquentes '},
    {'level': 4, 'label': 'Turbulences très fortes et constantes '},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Conditions de vol',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Choisis la cotation'),
            const SizedBox(height: AppSpacing.md),
            Column(
              children:
                  conditions.map((c) {
                    final level = c['level'] as int;
                    return RadioListTile<int>(
                      title: Text(c['label'] as String),
                      value: level,
                      groupValue: selectedLevel,
                      onChanged: (val) {
                        setState(() => selectedLevel = val);
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (selectedLevel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _buildNotice(selectedLevel!),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Une fermeture reste toujours une erreur de pilotage',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            PrimaryButton(
              label: 'Valider',
              icon: Icons.check,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(int level) {
    switch (level) {
      case 1:
        return const AppNotice(
          kind: NoticeKind.valid,
          title: 'Vigilance faible',
          message: 'Les conditions sont calmes.',
        );
      case 2:
      case 3:
        return const AppNotice(
          kind: NoticeKind.warning,
          title: 'Vigilance moyenne à élevée',
          message: 'Attention aux turbulences, restez vigilant.',
        );
      case 4:
        return const AppNotice(
          kind: NoticeKind.attention,
          title: 'Vigilance maximale',
          message: 'Conditions très turbulentes, vigilance extrême requise !',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
