import 'package:flutter/material.dart';
import 'package:paracheck/services/flight_repository.dart';
import '../models/flight.dart';
import '../widgets/stat_tile.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/home_button.dart';
import 'package:paracheck/widgets/primary_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlightRepository flightRepository = SharedPrefsFlightRepository();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ParaCheck',
      fab: null,
      body: Column(
        children: [
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FutureBuilder<List<Flight>>(
                  future: flightRepository.getAll(),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text('Erreur de chargement : ${snap.error}'),
                      );
                    }
                    final flights = snap.data ?? [];
                    final last3 = flights.take(3).toList();
                    if (last3.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Aucun vol enregistré pour le moment. Enregistrez votre premier vol dans la section Post-vol 👇',
                          key: ValueKey('no_flights_text'),
                        ),
                      );
                    }
                    return Column(
                      key: const ValueKey('flights_3last_list'),
                      children: [
                        for (final f in last3)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: StatTile(
                              label: f.formatDate(f.date),
                              value:
                                  'Durée : ${f.formatDuration(f.duration)} • Altitude : ${f.altitude}m',
                              icon: Icons.paragliding,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 24,
                ), // Plus d'espace avant le bouton historique
                Center(
                  child: PrimaryButton(
                    label: "Voir tous les vols",
                    icon: Icons.history,
                    onPressed:
                        () => {
                          Navigator.pushNamed(context, '/flights_history'),
                        },
                    key: const ValueKey('flights_history_button'),
                  ),
                ),

                const SizedBox(height: 50),

                // Deux gros boutons : Pré-vol et Post-vol
                HomeButton(
                  label: "Pre-flight",
                  icon: Icons.checklist,
                  onPressed: () {
                    Navigator.pushNamed(context, '/flight_condition');
                  },
                  key: const ValueKey('pre_flight_button'),
                ),
                const SizedBox(height: 50),
                HomeButton(
                  label: "Post-flight",
                  icon: Icons.assignment_turned_in,
                  onPressed: () {
                    Navigator.pushNamed(context, '/postflight_debrief');
                  },
                  key: const ValueKey('post_flight_button'),
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
