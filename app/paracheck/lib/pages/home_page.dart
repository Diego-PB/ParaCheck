import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import '../models/flights.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                  (flight) => Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: ListTile(
                      leading: const Icon(
                        Icons.paragliding,
                        color: Colors.white,
                      ),
                      title: Text(
                        flight.date,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Durée : ${flight.duration}   •   Altitude : ${flight.altitude}m',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
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
    );
  }
}
