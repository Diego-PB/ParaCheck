import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/flights_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/models/flight.dart';

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

Future<void> seedFlights(List<Flight> flights) async {
  // Toujours réinitialiser le store mocké AVANT d'afficher la page
  SharedPreferences.setMockInitialValues({});
  final repo = SharedPrefsFlightRepository();
  await repo.replaceAll(flights);
}

void main() {
  testWidgets('Loading → Empty state', (tester) async {
    await seedFlights(const []);

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));

    // Écran de chargement (spinner dans AppScaffold)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // État vide : icône + texte
    expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
    expect(find.text('Aucun vol enregistré pour le moment.'), findsOneWidget);
  });

  testWidgets('Affiche la liste des vols (2 items)', (tester) async {
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

    // 2 ListTile (un par vol)
    expect(find.byType(ListTile), findsNWidgets(2));

    // Quelques textes stables (site + morceaux de sous-titre)
    expect(find.text('Organya'), findsOneWidget);
    expect(find.text('Annecy'), findsOneWidget);
    expect(
      find.textContaining('•'),
      findsNWidgets(2),
    ); // date • durée • altitude
  });

  testWidgets('Tap → bottom sheet (sans radar)', (tester) async {
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

    // Tape sur le titre du ListTile (plus fiable que byType(ListTile).first)
    expect(find.text('Sornin'), findsOneWidget);
    await tester.tap(find.text('Sornin'));

    // Laisse le temps à l'animation du bottom sheet
    await tester.pump(); // démarre l’anim
    await tester.pump(const Duration(milliseconds: 300)); // durée typique
    await tester.pumpAndSettle();

    // Le bottom sheet est monté
    expect(find.byType(BottomSheet), findsOneWidget);

    // Contenu attendu
    expect(
      find.text('Sornin'),
      findsWidgets,
    ); // dans la liste + dans le sheet, autorise plusieurs
    expect(find.textContaining('Date :'), findsOneWidget);
    expect(find.textContaining('Durée :'), findsOneWidget);
    expect(find.textContaining('Altitude max :'), findsOneWidget);
    expect(find.text('Aucune rose enregistrée pour ce vol.'), findsOneWidget);

    // Fermer
    await tester.tap(find.widgetWithText(TextButton, 'Fermer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Sheet fermé
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Aucune rose enregistrée pour ce vol.'), findsNothing);
  });

  testWidgets('Suppression d’un vol via le dialog + snackbar', (tester) async {
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

    // On part bien avec 2 items
    expect(find.byType(ListTile), findsNWidgets(2));

    // Tap sur l’icône "Supprimer" du premier item (IconButton avec tooltip)
    // On cible par tooltip pour être robuste
    await tester.tap(find.byTooltip('Supprimer').first);
    await tester.pumpAndSettle();

    // Dialog : confirmer la suppression
    expect(find.text('Supprimer le vol'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    // Snackbar de confirmation
    expect(find.text('Vol supprimé'), findsOneWidget);

    // La liste est mise à jour (1 item restant)
    expect(find.byType(ListTile), findsNWidgets(1));
  });

  testWidgets('Pull-to-refresh → recharge la liste (1 → 2 items)', (
    tester,
  ) async {
    // 1 vol au départ
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

    // Pendant que la page est affichée, on ajoute un 2e vol dans le repo
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

    // Déclencher le RefreshIndicator (drag vers le bas au-dessus de la liste)
    // Un grand drag pour être sûr de dépasser le seuil
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump(); // commence l'animation du refresh
    await tester.pump(
      const Duration(seconds: 1),
    ); // laisse le onRefresh se jouer
    await tester.pumpAndSettle();

    // La liste doit refléter 2 items maintenant
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Erreur de chargement (JSON invalide) → message d’erreur', (
    tester,
  ) async {
    // JSON invalide pour key 'flights_v1' → getAll() lèvera une exception
    SharedPreferences.setMockInitialValues({'flights_v1': 'not a json array'});

    await tester.pumpWidget(const MaterialApp(home: FlightsHistoryPage()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Erreur de chargement des vols'),
      findsOneWidget,
    );
  });
}
