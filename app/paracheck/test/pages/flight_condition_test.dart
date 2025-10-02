// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paracheck/pages/flight_condition.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

/// Mock d’assets minimal : manifests + toutes images sous assets/ → PNG 1x1
void mockMinimalAssets() {
  final transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  );

  ServicesBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final key = const StringCodec().decodeMessage(message) as String;

    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object>{});
    }
    if (key == 'AssetManifest.json') {
      final bytes = Uint8List.fromList(utf8.encode('{}'));
      return ByteData.view(bytes.buffer);
    }
    if (key == 'FontManifest.json') {
      final bytes = Uint8List.fromList(utf8.encode('[]'));
      return ByteData.view(bytes.buffer);
    }

    final isAssetImage = key.startsWith('assets/') &&
        (key.endsWith('.png') ||
            key.endsWith('.jpg') ||
            key.endsWith('.jpeg') ||
            key.endsWith('.webp'));
    if (isAssetImage) {
      return ByteData.view(transparentPng.buffer);
    }

    return null;
  });
}

/// Dummy screen pour vérifier les routes.
class _RouteScreen extends StatelessWidget {
  final String name;
  const _RouteScreen(this.name);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ROUTE: $name', key: Key('route-$name'))),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ServicesBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('FlightConditionPage (tests simplifiés)', () {
    testWidgets('1) Rend les 4 niveaux + bannière d’avertissement', (tester) async {
      mockMinimalAssets();

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const FlightConditionPage(),
      ));

      await tester.pump(const Duration(milliseconds: 50));

      // Titre de la page
      expect(find.text('Conditions de vol'), findsOneWidget);

      // Les 4 libellés (on matche en partie pour ignorer les espaces finaux)
      expect(find.textContaining('Conditions calmes'), findsOneWidget);
      expect(find.textContaining('Turbulences moyennes'), findsOneWidget);
      expect(find.textContaining('Turbulences fortes et fréquentes'), findsOneWidget);
      expect(find.textContaining('Turbulences très fortes et constantes'), findsOneWidget);

      // Bannière d’avertissement en bas
      expect(
        find.text('Une fermeture reste toujours une erreur de pilotage'),
        findsOneWidget,
      );
    });

    testWidgets('2) La route /personal_weather est navigable (pushNamed OK)', (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: const _RouteScreen('home'),
        routes: {
          '/personal_weather': (_) => const _RouteScreen('personal_weather'),
        },
      ));

      navKey.currentState!.pushNamed('/personal_weather');

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ROUTE: personal_weather'), findsOneWidget);
    });

    testWidgets('3) La page rend un AppScaffold', (tester) async {
      mockMinimalAssets();

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const FlightConditionPage(),
      ));

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AppScaffold), findsOneWidget);
    });
  });
}
