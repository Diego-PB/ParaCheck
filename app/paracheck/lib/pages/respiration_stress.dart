import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/secondary.button.dart';
import 'package:paracheck/design/spacing.dart';

class RespirationStressPage extends StatelessWidget {
  const RespirationStressPage({super.key});

  Widget _title(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Respiration & Stress',
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/mavie');
      },
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.self_improvement, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gestion de la respiration et du stress',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Avant le vol
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context, 'Avant le vol'),
                  const SizedBox(height: 8),
                  _bullet('Exercice de cohérence cardiaque pour gérer le stress avant le décollage.'),
                  _bullet('Faire 3 à 4 cycles : inspirer 5 s, bloquer 5 s, puis expirer 7 s.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pendant le vol
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context, 'Pendant le vol'),
                  const SizedBox(height: 8),
                  _bullet('Garder conscience de sa respiration pour éviter les phases d’apnée ou une respiration trop thoracique.'),
                  _bullet('Favoriser la respiration abdominale en expirant un grand coup.'),
                  _bullet('Verbaliser les actions à voix haute ou chanter pour focaliser son attention.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SecondaryButton(
                label: "Départ du vol !",
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}