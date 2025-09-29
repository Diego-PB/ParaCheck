// test/pages/breathing_stress_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/breathing_stress.dart';

// Observer pour vérifier la route poussée
class TestNavObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  Widget _appWithRoutes(Widget child, {NavigatorObserver? observer}) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: child,
      routes: {
        '/homepage': (_) => const _RouteScreen(name: 'homepage'),
        '/mavie': (_) => const _RouteScreen(name: 'mavie'),
      },
      navigatorObservers: [
        if (observer != null) observer,
      ],
    );
  }

  // Finder texte tolérant : casse ignorée, NBSP/NNBSP normalisées
  Finder _textContains(String needle) {
    final target = needle.toLowerCase();
    return find.byWidgetPredicate((w) {
      if (w is Text) {
        final raw = (w.data ?? w.textSpan?.toPlainText()) ?? '';
        final norm = raw
            .toLowerCase()
            .replaceAll('\u00A0', ' ')
            .replaceAll('\u202F', ' ');
        return norm.contains(target);
      }
      return false;
    });
  }

  group('BreathingStressPage — tests pertinents', () {
    testWidgets('affiche titres et toutes les puces exactes', (tester) async {
      await tester.pumpWidget(_appWithRoutes(const BreathingStressPage()));
      await tester.pumpAndSettle();

      // En-tête + icône
      expect(find.text('Gestion de la respiration et du stress'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);

      // Sections
      expect(find.text('Avant le vol'), findsOneWidget);
      expect(find.text('Pendant le vol'), findsOneWidget);

      // Puces EXACTES (2 + 3)
      expect(
        find.text('Exercice de cohérence cardiaque pour gérer le stress avant le décollage.'),
        findsOneWidget,
      );
      expect(
        find.text('Faire 3 à 4 cycles : inspirer 5 s, bloquer 5 s, puis expirer 7 s.'),
        findsOneWidget,
      );
      expect(
        find.text('Garder conscience de sa respiration pour éviter les phases d’apnée ou une respiration trop thoracique.'),
        findsOneWidget,
      );
      expect(
        find.text('Favoriser la respiration abdominale en expirant un grand coup.'),
        findsOneWidget,
      );
      expect(
        find.text('Verbaliser les actions à voix haute ou chanter pour focaliser son attention.'),
        findsOneWidget,
      );
    });

    testWidgets('structure de page OK (ListView + 2 Cards + 5 puces)', (tester) async {
      await tester.pumpWidget(_appWithRoutes(const BreathingStressPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));

      final bullets = find.byWidgetPredicate((w) {
        if (w is Text && w.data != null) {
          final d = w.data!;
          return d.trimLeft().startsWith('•');
        }
        return false;
      });
      expect(bullets, findsNWidgets(5));
    });
  });
}

// Écran factice pour routes cibles
class _RouteScreen extends StatelessWidget {
  final String name;
  const _RouteScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ROUTE: $name', key: Key('route-$name'))),
    );
  }
}
