/*
 Unit tests for the HomePage in the ParaCheck application.
 This test suite verifies HomePage behaviors including loading and empty states,
 display of up to three recent flights as StatTile widgets,
 navigation to history, pre-flight, and post-flight screens via buttons,
 and error handling when flight data fails to load.
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/models/flight.dart';
import 'package:paracheck/widgets/stat_tile.dart';

/// Helper to create Flight instances for testing with minimal boilerplate
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

/// Seeds the SharedPreferences-backed repository with provided flights.
/// Must reset the mock store before displaying HomePage to avoid stale data.
Future<void> seedFlights(List<Flight> flights) async {
  SharedPreferences.setMockInitialValues({}); // Clear existing mock data
  final repo = SharedPrefsFlightRepository();
  await repo.replaceAll(flights);
}

void main() {
  testWidgets('HomePage → loading puis état vide', (tester) async {
    await seedFlights(const []); // No flights in repo

    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // 1) While data is loading, expect a spinner in the scaffold body
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 2) After loading, empty state should show text and no StatTile
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('no_flights_text')), findsOneWidget);
    expect(find.byType(StatTile), findsNothing);
  });

  testWidgets('HomePage → affiche au maximum 3 StatTile (take(3))', (tester) async {
    // Seed with four flights but HomePage should only display the last three
    await seedFlights([
      makeFlight(
        id: 'f1',
        site: 'Organya',
        date: DateTime(2025, 9, 10),
        duration: const Duration(minutes: 10),
        altitude: 800,
      ),
      makeFlight(
        id: 'f2',
        site: 'Annecy',
        date: DateTime(2025, 9, 15),
        duration: const Duration(minutes: 20),
        altitude: 900,
      ),
      makeFlight(
        id: 'f3',
        site: 'Sornin',
        date: DateTime(2025, 9, 18),
        duration: const Duration(minutes: 30),
        altitude: 1000,
      ),
      makeFlight(
        id: 'f4',
        site: 'Auriol',
        date: DateTime(2025, 9, 21),
        duration: const Duration(minutes: 40),
        altitude: 1100,
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // The widget with key 'flights_3last_list' should exist
    expect(find.byKey(const ValueKey('flights_3last_list')), findsOneWidget);

    // Only three StatTile widgets should be rendered
    expect(find.byType(StatTile), findsNWidgets(3));

    // Each tile should display duration and altitude texts
    expect(find.textContaining('Durée :'), findsNWidgets(3));
    expect(find.textContaining('Altitude :'), findsNWidgets(3));
  });

  testWidgets(
    'HomePage → navigation (historique / pré-vol / post-vol) via Keys',
    (tester) async {
      await seedFlights(const []); // No flights needed for navigation tests

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/flights_history': (_) => const AppScaffold(
                  title: 'ParaCheck',
                  body: Center(child: Text('HISTORY_SCREEN')),
                ),
            '/flight_condition': (_) => const AppScaffold(
                  title: 'ParaCheck',
                  body: Center(child: Text('PRE_SCREEN')),
                ),
            '/postflight_debrief': (_) => const AppScaffold(
                  title: 'ParaCheck',
                  body: Center(child: Text('POST_SCREEN')),
                ),
          },
          home: const HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap history button and verify navigation
      await tester.tap(find.byKey(const ValueKey('flights_history_button')));
      await tester.pumpAndSettle();
      expect(find.text('HISTORY_SCREEN'), findsOneWidget);

      // Pop back to HomePage
      Navigator.of(tester.element(find.text('HISTORY_SCREEN'))).pop();
      await tester.pumpAndSettle();

      // Tap pre-flight button and verify navigation
      await tester.tap(find.byKey(const ValueKey('pre_flight_button')));
      await tester.pumpAndSettle();
      expect(find.text('PRE_SCREEN'), findsOneWidget);

      Navigator.of(tester.element(find.text('PRE_SCREEN'))).pop();
      await tester.pumpAndSettle();

      // Tap post-flight button and verify navigation
      await tester.tap(find.byKey(const ValueKey('post_flight_button')));
      await tester.pumpAndSettle();
      expect(find.text('POST_SCREEN'), findsOneWidget);
    },
  );

  testWidgets(
    'HomePage → affiche le message d’erreur si getAll() plante (JSON invalide)',
    (tester) async {
      // Inject invalid JSON to simulate repository failure
      SharedPreferences.setMockInitialValues({
        'flights_v1': 'not a json array',
      });

      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Error message should be displayed containing 'Erreur de chargement'
      expect(find.textContaining('Erreur de chargement'), findsOneWidget);
    },
  );
}
