import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/design/spacing.dart';

/// Simple, static page to guide breathing and stress management.
/// Uses small helper widgets for titles and bullet rows.
class BreathingStressPage extends StatelessWidget {
  const BreathingStressPage({super.key});

  /// Section title with consistent styling.
  /// Kept as a helper to avoid repeating style code.
  Widget _title(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  /// Bullet line: a dot followed by flexible text that wraps on multiple lines.
  /// Using a Row with an Expanded to keep the bullet aligned on the first line.
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),          // The bullet symbol
          Expanded(child: Text(text)), // The bullet content
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // App bar title
      title: 'Respiration & Stress',

      // Show a back/return button in the scaffold header
      showReturnButton: true,

      // Route to navigate back to when the return button is pressed
      onReturn: () {
        Navigator.pushNamed(context, '/mavie');
      },

      // Main scrollable content
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),

        children: [
          // ----- Header / Intro card -----
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Subtle background aligned with the theme
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.4),
              // Thin border using the theme's outline color
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Icon to visually indicate calm/meditation
                Icon(
                  Icons.self_improvement,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),

                // Page headline
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

          // ----- Pre-flight section -----
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context, 'Avant le vol'),
                  const SizedBox(height: 8),

                  // Actionable breathing tips before takeoff
                  _bullet(
                    'Exercice de cohérence cardiaque pour gérer le stress avant le décollage.',
                  ),
                  _bullet(
                    'Faire 3 à 4 cycles : inspirer 5 s, bloquer 5 s, puis expirer 7 s.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ----- In-flight section -----
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context, 'Pendant le vol'),
                  const SizedBox(height: 8),

                  // Reminders for breathing and attention focus during flight
                  _bullet(
                    'Garder conscience de sa respiration pour éviter les phases d’apnée ou une respiration trop thoracique.',
                  ),
                  _bullet(
                    'Favoriser la respiration abdominale en expirant un grand coup.',
                  ),
                  _bullet(
                    'Verbaliser les actions à voix haute ou chanter pour focaliser son attention.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ----- Primary action row -----
          Row(
            children: [
              // Secondary styled button that starts the flight flow
              SecondaryButton(
                label: "Départ du vol !",
                onPressed: () {
                  // Navigate to the app's home page when starting the flight
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
