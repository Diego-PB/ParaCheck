import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/design/spacing.dart';

class BreathingStressPage extends StatelessWidget {
  const BreathingStressPage({super.key});

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
      title: 'Breathing & Stress',
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/mfwia');
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
                    'Breathing and Stress Management',
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
                  _title(context, 'Before the flight'),
                  const SizedBox(height: 8),
                  _bullet('Heart coherence exercise to manage stress before takeoff.'),
                  _bullet('Do 3 to 4 cycles: inhale for 5 seconds, hold for 5 seconds, then exhale for 7 seconds.'),
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
                  _title(context, 'During the flight'),
                  const SizedBox(height: 8),
                  _bullet('Stay aware of your breathing to avoid apnea or overly thoracic breathing.'),
                  _bullet('Encourage abdominal breathing by exhaling forcefully.'),
                  _bullet('Verbalize actions out loud or sing to focus attention.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SecondaryButton(
                label: "Flight Departure !",
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