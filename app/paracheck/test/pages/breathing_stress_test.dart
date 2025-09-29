// test/pages/breathing_stress_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/breathing_stress.dart';

void main() {
  Widget appWithRoutes(Widget child) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: child,
    );
  }

  group('BreathingStressPage — smoke', () {
    testWidgets('rend l’en-tête et l’icône', (tester) async {
      await tester.pumpWidget(appWithRoutes(const BreathingStressPage()));
      await tester.pumpAndSettle();

      expect(find.text('Gestion de la respiration et du stress'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    });

    testWidgets('affiche les sections et la structure', (tester) async {
      await tester.pumpWidget(appWithRoutes(const BreathingStressPage()));
      await tester.pumpAndSettle();

      expect(find.text('Avant le vol'), findsOneWidget);
      expect(find.text('Pendant le vol'), findsOneWidget);

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('contient bien 5 puces et le dernier conseil', (tester) async {
      await tester.pumpWidget(appWithRoutes(const BreathingStressPage()));
      await tester.pumpAndSettle();

      // 2 puces avant + 3 puces pendant = 5
      final bullets = find.byWidgetPredicate((w) {
        if (w is Text && w.data != null) {
          final d = w.data!;
          return d.trimLeft().startsWith('•');
        }
        return false;
      });
      expect(bullets, findsNWidgets(5));

      // Dernier conseil exact présent
      expect(
        find.text('Verbaliser les actions à voix haute ou chanter pour focaliser son attention.'),
        findsOneWidget,
      );
    });
  });
}
