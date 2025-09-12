import 'package:flutter/material.dart';
import '../models/flights.dart';
import '../widgets/stat_tile.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/home_button.dart';
import 'package:paracheck/widgets/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paracheck',
      fab: null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 32.0,
              left: 16,
              right: 16,
              bottom: 8,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...sampleFlights.map(
                  (flight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: StatTile(
                      label: flight.date,
                      value:
                          'Durée : ${flight.duration} • Altitude : ${flight.altitude}m',
                      icon: Icons.paragliding,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ), // Plus d'espace avant le bouton historique
                Center(
                  child: PrimaryButton(
                    label: "Voir l'historique",
                    icon: Icons.history,
                    onPressed: () => {},
                  ),
                ),

                const SizedBox(height: 50),

                // Deux gros boutons : Pré-vol et Post-vol
                HomeButton(
                  label: "Pré-vol",
                  icon: Icons.checklist,
                  onPressed: () {
                    Navigator.pushNamed(context, '/condition_vol');
                  },
                ),
                const SizedBox(height: 50),
                HomeButton(
                  label: "Post-vol",
                  icon: Icons.assignment_turned_in,
                  onPressed: () {
                    Navigator.pushNamed(context, '/debrief_postvol');
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
