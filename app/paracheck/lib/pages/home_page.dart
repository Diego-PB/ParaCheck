import 'package:flutter/material.dart';
import 'package:paracheck/widgets/home_button.dart';
import 'package:paracheck/widgets/primary_button.dart';
import '../models/flights.dart';
import '../widgets/stat_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Suppression du floatingActionButton
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 32.0,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Center(
              child: Text(
                'Paracheck',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
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
                          'Durée : ${flight.duration} • Altitude :${flight.altitude}m',
                      icon: Icons.paragliding,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: PrimaryButton(
                    label: "Voir l'historique",
                    icon: Icons.history,
                    onPressed: () {
                      // Action à définir plus tard
                    },
                    size: 16,
                  ),
                ),
                const SizedBox(height: 50),
                // Deux gros boutons : Pré-vol et Post-vol
                HomeButton(
                  label: "Pré-vol",
                  icon: Icons.checklist,
                  onPressed: () {
                    // Action à définir plus tard
                  },
                ),
                const SizedBox(height: 50),
                HomeButton(
                  label: "Post-vol",
                  icon: Icons.assignment_turned_in,
                  onPressed: () {
                    // Action à définir plus tard
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(height: 70, color: Theme.of(context).colorScheme.primary),
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  shape: const CircleBorder(),
                  elevation: 6,
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: ClipOval(
                          child: Image.asset(
                            'lib/assets/Paracheck_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
