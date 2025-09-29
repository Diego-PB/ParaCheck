/*
 Unit tests for the BreathingStressPage in ParaCheck application.
 This test file validates the breathing and stress management page content,
 structure, and UI elements. It ensures all expected text, sections, bullet points,
 and navigation elements are properly displayed and functional.
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/breathing_stress.dart';

/// Test observer to track navigation route pushes
class TestNavObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  // Helper to wrap widgets with MaterialApp and routing for testing
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

  // Text finder with case-insensitive matching and whitespace normalization
  // Handles non-breaking spaces (NBSP/NNBSP) that may appear in Flutter text
  Finder _textContains(String needle) {
    final target = needle.toLowerCase();
    return find.byWidgetPredicate((w) {
      if (w is Text) {
        final raw = (w.data ?? w.textSpan?.toPlainText()) ?? '';
        final norm = raw
            .toLowerCase()
            .replaceAll('\u00A0', ' ')    // Replace NBSP with regular space
            .replaceAll('\u202F', ' ');   // Replace NNBSP with regular space
        return norm.contains(target);
      }
      return false;
    });
  }

  group('BreathingStressPage — tests pertinents', () {
    testWidgets('affiche titres et toutes les puces exactes', (tester) async {
      await tester.pumpWidget(_appWithRoutes(const BreathingStressPage()));
      await tester.pumpAndSettle();

      // Main header with icon
      expect(find.text('Gestion de la respiration et du stress'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);

      // Section headers
      expect(find.text('Avant le vol'), findsOneWidget);
      expect(find.text('Pendant le vol'), findsOneWidget);

      // Verify all 5 bullet points are present with exact text (2 pre-flight + 3 in-flight)
      expect(
        find.text('Exercice de cohérence cardiaque pour gérer le stress avant le décollage.'),
        findsOneWidget,
      );
      expect(
        find.text('Faire 3 à 4 cycles : inspirer 5 s, bloquer 5 s, puis expirer 7 s.'),
        findsOneWidget,
      );
      expect(
        find.text('Garder conscience de sa respiration pour éviter les phases d\'apnée ou une respiration trop thoracique.'),
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

      // Verify overall page structure
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));  // One card per section

      // Count bullet points by checking for '•' character at text start
      final bullets = find.byWidgetPredicate((w) {
        if (w is Text && w.data != null) {
          final d = w.data!;
          return d.trimLeft().startsWith('•');
        }
        return false;
      });
      expect(bullets, findsNWidgets(5));  // Total expected bullet points
    });
  });
}

/// Mock screen widget for testing navigation routes
class _RouteScreen extends StatelessWidget {
  final String name;  // Route identifier for testing purposes
  
  const _RouteScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ROUTE: $name', key: Key('route-$name'))),
    );
  }
}
