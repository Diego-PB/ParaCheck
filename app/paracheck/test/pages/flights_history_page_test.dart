/* Unit tests for the FlightsHistoryPage in the ParaCheck application.
 This test suite covers various scenarios on the flight history screen:
 - Loading state with a spinner
 - Empty state message when no flights are stored
 - Correct display of a list of saved flights
 - Opening a bottom sheet with flight details (no radar data case)
 - Deletion of a flight via confirmation dialog and snackbar feedback
 - Pull-to-refresh behavior updating the list when repository data changes
 - Error handling when stored JSON is invalid
 */


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/flights_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/models/flight.dart';

/// Helper to create Flight instances for tests with minimal boilerplate
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

/// Seeds the mock SharedPreferences-backed repository with the given flights.
/// MUST reset the mock storage before injecting data to ensure test isolation.
Future<void> seedFlights(List<Flight> flights) async {
  SharedPreferences.setMockInitialValues({}); // Clear existing mock values
  final repo = SharedPrefsFlightRepository();
  await repo.replaceAll(flights);
}

void main() {
  testWidgets('Loading → Empty state', (tester) async {
    await seedFlights(const []); // No flights initially

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));

    // While loading, a CircularProgressIndicator should be shown inside the scaffold
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Wait for load to complete

    // Verify empty state UI: hourglass icon and no-flights text
    expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
    expect(find.text('Aucun vol enregistré pour le moment.'), findsOneWidget);
  });

  testWidgets('Affiche la liste des vols (2 items)', (tester) async {
    // Seed with two flights
    await seedFlights([
      makeFlight(
        id: 'f1',
        site: 'Organya',
        date: DateTime(2025, 9, 10),
        duration: const Duration(minutes: 35),
        altitude: 980,
      ),
      makeFlight(
        id: 'f2',
        site: 'Annecy',
        date: DateTime(2025, 9, 12),
        duration: const Duration(hours: 1, minutes: 5),
        altitude: 1550,
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));
    await tester.pumpAndSettle();

    // Expect two ListTile widgets, one per stored flight
    expect(find.byType(ListTile), findsNWidgets(2));

    // Check that each flight's site name appears
    expect(find.text('Organya'), findsOneWidget);
    expect(find.text('Annecy'), findsOneWidget);

    // Subtitle should contain bullet separators for date, duration, altitude
    expect(find.textContaining('•'), findsNWidgets(2));
  });

  testWidgets('Tap → bottom sheet (sans radar)', (tester) async {
    // Seed with a single flight without radar data
    await seedFlights([
      makeFlight(
        id: 'f1',
        site: 'Sornin',
        date: DateTime(2025, 9, 15),
        duration: const Duration(minutes: 42),
        altitude: 1200,
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));
    await tester.pumpAndSettle();

    // Tap the flight title to open its detail bottom sheet
    expect(find.text('Sornin'), findsOneWidget);
    await tester.tap(find.text('Sornin'));

    // Allow bottom sheet animation to complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify bottom sheet presence
    expect(find.byType(BottomSheet), findsOneWidget);

    // Detail fields in the sheet: site, date, duration, max altitude, no radar message
    expect(find.text('Sornin'), findsWidgets);
    expect(find.textContaining('Date :'), findsOneWidget);
    expect(find.textContaining('Durée :'), findsOneWidget);
    expect(find.textContaining('Altitude max :'), findsOneWidget);
    expect(find.text('Aucune rose enregistrée pour ce vol.'), findsOneWidget);

    // Close the sheet via 'Fermer' button
    await tester.tap(find.widgetWithText(TextButton, 'Fermer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Bottom sheet should be dismissed
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Aucune rose enregistrée pour ce vol.'), findsNothing);
  });

  testWidgets('Suppression d’un vol via le dialog + snackbar', (tester) async {
    // Seed with two flights
    await seedFlights([
      makeFlight(
        id: 'f1',
        site: 'Organya',
        date: DateTime(2025, 9, 10),
        duration: const Duration(minutes: 35),
        altitude: 980,
      ),
      makeFlight(
        id: 'f2',
        site: 'Annecy',
        date: DateTime(2025, 9, 12),
        duration: const Duration(hours: 1, minutes: 5),
        altitude: 1550,
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));
    await tester.pumpAndSettle();

    // Ensure two items are shown initially
    expect(find.byType(ListTile), findsNWidgets(2));

    // Tap delete icon button on first flight via tooltip selector
    await tester.tap(find.byTooltip('Supprimer').first);
    await tester.pumpAndSettle();

    // Confirm deletion in dialog
    expect(find.text('Supprimer le vol'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    // Snackbar confirmation should appear
    expect(find.text('Vol supprimé'), findsOneWidget);

    // List should now contain only one flight
    expect(find.byType(ListTile), findsNWidgets(1));
  });

 testWidgets('Pull-to-refresh → recharge la liste (1 → 2 items)', (tester) async {
    // Seed with a single flight
    await seedFlights([
      makeFlight(
        id: 'f1',
        site: 'Organya',
        date: DateTime(2025, 9, 10),
        duration: const Duration(minutes: 35),
        altitude: 980,
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(1));

    // Dynamically add a second flight to the repository after page load
    final repo = SharedPrefsFlightRepository();
    await repo.add(
      makeFlight(
        id: 'f2',
        site: 'Annecy',
        date: DateTime(2025, 9, 12),
        duration: const Duration(hours: 1, minutes: 5),
        altitude: 1550,
      ),
    );

    // Perform pull-to-refresh gesture on the list
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump(); // start refresh animation
    await tester.pump(const Duration(seconds: 1)); // wait for onRefresh
    await tester.pumpAndSettle();

    // List should update to show two flights
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Erreur de chargement (JSON invalide) → message d’erreur', (tester) async {
    // Set invalid JSON in mock storage to trigger load error
    SharedPreferences.setMockInitialValues({'flights_v1': 'not a json array'});

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));
    await tester.pumpAndSettle();

    // Error message should inform user of load failure
    expect(
      find.textContaining('Erreur de chargement des vols'),
      findsOneWidget,
    );
  });
}