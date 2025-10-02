/*
 * This page allows the user to select the current flight condition (weather/turbulence level) using radio buttons.
 * The selected value is saved locally using SharedPreferences and can be used by other parts of the app.
 * The page displays a contextual message based on the selected condition and a warning at the bottom.
 * After validation, the user is redirected to the next step.
 */

import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/design/spacing.dart';
import '../widgets/section_title.dart';
import '../widgets/app_notice.dart';
import '../widgets/primary_button.dart';
import '../design/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlightConditionPage extends StatefulWidget {
  const FlightConditionPage({super.key});

  @override
  State<FlightConditionPage> createState() => _FlightConditionPageState();
}

class _FlightConditionPageState extends State<FlightConditionPage> {
  // Key used to store the selected flight condition in SharedPreferences
  static const _key = 'condition_vol_level';

  // Stores the currently selected flight condition (null if not selected)
  int? selectedLevel;

  // List of available flight conditions for user selection
  final conditions = [
    {'level': 1, 'label': 'Conditions calmes '},
    {'level': 2, 'label': 'Turbulences moyennes et localisées '},
    {'level': 3, 'label': 'Turbulences fortes et fréquentes '},
    {'level': 4, 'label': 'Turbulences très fortes et constantes '},
  ];

  @override
  void initState() {
    super.initState();
    // You could load the saved condition here if you want to restore previous selection
  }

  Future<void> _saveLevel(int level) async {
    // Saves the selected flight condition to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, level);
  }

  @override
  Widget build(BuildContext context) {
    // Main UI structure for the flight condition selection page
    return AppScaffold(
      title: 'Conditions de vol',
      showReturnButton: true,
      // Handles navigation when the return button is pressed
      onReturn: () {
        Navigator.pushNamed(context, '/homepage');
      },
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the radio group section
            const SectionTitle('Choix de la cotation'),
            const SizedBox(height: AppSpacing.md),

            // Radio buttons for selecting the flight condition
            RadioGroup<int>(
              groupValue: selectedLevel,
              onChanged: (val) => setState(() => selectedLevel = val),
              child: Column(
                children:
                    conditions.map((c) {
                      final level = c['level'] as int;
                      return RadioListTile<int>(
                        title: Text(c['label'] as String),
                        value:
                            level, 
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Show contextual message if a condition is selected
            if (selectedLevel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _buildNotice(selectedLevel!),
              ),

            const Spacer(),

            // Warning message always shown at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Une fermeture reste toujours une erreur de pilotage',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Validation button aligned to the right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(
                    label: 'Valider',
                    icon: Icons.check,
                    onPressed:
                        selectedLevel == null
                            ? null
                            : () async {
                              // Save the selected condition and navigate to the next page
                              await _saveLevel(selectedLevel!);
                              if (!context.mounted) return;
                              Navigator.pushNamed(context, '/personal_weather');
                            },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(int level) {
    // Returns a contextual message widget based on the selected flight condition
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
