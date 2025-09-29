import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/pages/splash_screen.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/widgets/logo_widget.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: child,
      );

  testWidgets('SplashScreen → affiche le logo et fond blanc au départ',
      (tester) async {
    await tester.pumpWidget(wrap(const SplashScreen()));

    // Le logo est visible
    expect(find.byType(LogoWidget), findsOneWidget);

    // Fond blanc (backgroundColor du Scaffold)
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, equals(Colors.white));
  });

  testWidgets('SplashScreen → navigue vers HomePage après ~2s',
      (tester) async {
    await tester.pumpWidget(wrap(const SplashScreen()));

    // Avant 2s, on est toujours sur le splash
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.byType(LogoWidget), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    // Laisse passer le délai (un poil plus que 2s pour être safe)
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // On est bien sur HomePage
    expect(find.byType(HomePage), findsOneWidget);
  });
}
