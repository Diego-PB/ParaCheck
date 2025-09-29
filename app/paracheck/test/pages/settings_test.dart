import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/settings.dart';
import 'package:paracheck/widgets/app_notice.dart';
import 'package:paracheck/widgets/section_title.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: child,
      );

  group('SettingsPage — smoke', () {
    testWidgets('rend le titre, la section et la notice de base', (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));
      await tester.pumpAndSettle();

      // Titre AppScaffold
      expect(find.text('Paramètres'), findsOneWidget);

      // Titre de section
      expect(
        find.widgetWithText(SectionTitle, 'Sauvegarde & transfert (fichier .json)'),
        findsOneWidget,
      );

      // Notice d’intro (attention) présente
      expect(find.byType(AppNotice), findsOneWidget);
      expect(find.text('Export / Import'), findsOneWidget);
      expect(
        find.textContaining('Exportez vos données locales (SharedPreferences)'),
        findsOneWidget,
      );
    });

    testWidgets('affiche les deux boutons (export / import) et l’icône download', (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));
      await tester.pumpAndSettle();

      // Boutons par leur libellé
      expect(find.text('Exporter vers un fichier'), findsOneWidget);
      expect(find.text('Importer depuis un fichier'), findsOneWidget);

      // Icône sur le bouton d’export
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('le switch "Remplacer tout" bascule bien de false → true', (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Valeur initiale
      var sw = tester.widget<Switch>(switchFinder);
      expect(sw.value, isFalse);

      // Tap pour basculer
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Valeur mise à jour
      sw = tester.widget<Switch>(switchFinder);
      expect(sw.value, isTrue);

      // Le texte explicatif est présent
      expect(
        find.text(
          "Remplacer tout lors de l'import (sinon, les données existantes sont conservées)",
        ),
        findsOneWidget,
      );
    });
  });
}
