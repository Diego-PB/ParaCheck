import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/models/flight.dart'; 
import 'package:paracheck/widgets/stat_tile.dart';

Flight makeFlight({
  required String id,
  required String site,
  required DateTime date,
  required Duration duration,
  required int altitude,
}) {
  return Flight(
    id: id,
    site: site,
    date: date,
    duration: duration,
    altitude: altitude,
  );
}

// Seed du repo réel dans le store in-memory de SharedPreferences.
// À appeler AVANT d’afficher HomePage, sinon le repo aura déjà lu autre chose.
Future<void> seedFlights(List<Flight> flights) async {
  // Réinitialise le store mocké
  SharedPreferences.setMockInitialValues({});

  final repo = SharedPrefsFlightRepository();

  await repo.replaceAll(flights);
}

void main() {
  testWidgets('HomePage → loading puis état vide', (tester) async {
    await seedFlights(const []);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // 1) spinner pendant la résolution du FutureBuilder
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 2) affichage de l’état vide
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('no_flights_text')), findsOneWidget);
    expect(find.byType(StatTile), findsNothing);
  });

  testWidgets('HomePage → affiche au maximum 3 StatTile (take(3))', (tester) async {
    await seedFlights([
      makeFlight(
        id: 'f1', site: 'Organya',
        date: DateTime(2025, 9, 10),
        duration: const Duration(hours: 0, minutes: 10),
        altitude: 800,
      ),
      makeFlight(
        id: 'f2', site: 'Annecy',
        date: DateTime(2025, 9, 15),
        duration: const Duration(hours: 0, minutes: 20),
        altitude: 900,
      ),
      makeFlight(
        id: 'f3', site: 'Sornin',
        date: DateTime(2025, 9, 18),
        duration: const Duration(hours: 0, minutes: 30),
        altitude: 1000,
      ),
      makeFlight(
        id: 'f4', site: 'Auriol',
        date: DateTime(2025, 9, 21),
        duration: const Duration(hours: 0, minutes: 40),
        altitude: 1100,
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // La liste des vols est affichée
    expect(find.byKey(const ValueKey('flights_3last_list')), findsOneWidget);

    // take(3) → exactement 3 tuiles
    expect(find.byType(StatTile), findsNWidgets(3));

    // Vérifs textuelles souples
    expect(find.textContaining('Durée :'), findsNWidgets(3));
    expect(find.textContaining('Altitude :'), findsNWidgets(3));
  });

  testWidgets('HomePage → navigation (historique / pré-vol / post-vol) via Keys', (tester) async {
    await seedFlights(const []);

    await tester.pumpWidget(MaterialApp(
      routes: {
        '/flights_history': (_) => const AppScaffold(title: 'ParaCheck', body: Center(child: Text('HISTORY_SCREEN'))),
        '/flight_condition': (_) => const AppScaffold(title: 'ParaCheck', body: Center(child: Text('PRE_SCREEN'))),
        '/postflight_debrief': (_) => const AppScaffold(title: 'ParaCheck', body: Center(child: Text('POST_SCREEN'))),
      },
      home: const HomePage(),
    ));
    await tester.pumpAndSettle();

    // Historique
    await tester.tap(find.byKey(const ValueKey('flights_history_button')));
    await tester.pumpAndSettle();
    expect(find.text('HISTORY_SCREEN'), findsOneWidget);

    // Retour Home
    Navigator.of(tester.element(find.text('HISTORY_SCREEN'))).pop();
    await tester.pumpAndSettle();

    // Pré-vol
    await tester.tap(find.byKey(const ValueKey('pre_flight_button')));
    await tester.pumpAndSettle();
    expect(find.text('PRE_SCREEN'), findsOneWidget);

    Navigator.of(tester.element(find.text('PRE_SCREEN'))).pop();
    await tester.pumpAndSettle();

    // Post-vol
    await tester.tap(find.byKey(const ValueKey('post_flight_button')));
    await tester.pumpAndSettle();
    expect(find.text('POST_SCREEN'), findsOneWidget);
  });

  testWidgets('HomePage → affiche le message d’erreur si getAll() plante (JSON invalide)', (tester) async {
    // Injecte un JSON invalide directement dans le store mocké
    SharedPreferences.setMockInitialValues({
      'flights_v1': 'not a json array', // jsonDecode va lever une exception dans getAll()
    });

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // Le builder affiche : "Erreur de chargement : ${snap.error}"
    expect(find.textContaining('Erreur de chargement'), findsOneWidget);
  });
}
