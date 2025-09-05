import 'package:flutter/material.dart';
import '../widgets/logo_widget.dart';
import '../models/flights.dart'; // <-- Import du modèle de vols

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Ne fait rien pour l'instant
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau vol', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Utilisation des données de sampleFlights
                ...sampleFlights.map((flight) => Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: const Icon(Icons.paragliding, color: Colors.white),
                    title: Text(
                      flight.date,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Durée : ${flight.duration}   •   Altitude : ${flight.altitude}m',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                )),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    onPressed: () {
                      // Action à définir plus tard
                    },
                    child: const Text('Voir l\'historique'),
                  ),
                ),
                const SizedBox(height: 8),
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