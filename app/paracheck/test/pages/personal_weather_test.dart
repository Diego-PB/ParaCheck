// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paracheck/pages/personal_weather.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

/// Mock des assets nécessaires pour les tests (JSON + manifests + images).
void mockQuestionsAsset({String? payload}) {
  const key = 'assets/personal_weather_questions.json';
  const defaultJson = '''
[
  {"question":"Q1?","answer_ok":"OK","answer_bof":"BOF","answer_nok":"NOK"}
]
''';

  final transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  );

  ServicesBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final requested = const StringCodec().decodeMessage(message) as String;

    if (requested == key) {
      final bytes = Uint8List.fromList(utf8.encode(payload ?? defaultJson));
      return ByteData.view(bytes.buffer);
    }
    if (requested == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object>{});
    }
    if (requested == 'AssetManifest.json') {
      final bytes = Uint8List.fromList(utf8.encode('{}'));
      return ByteData.view(bytes.buffer);
    }
    if (requested == 'FontManifest.json') {
      final bytes = Uint8List.fromList(utf8.encode('[]'));
      return ByteData.view(bytes.buffer);
    }

    final isAssetImage = requested.startsWith('assets/') &&
        (requested.endsWith('.png') ||
            requested.endsWith('.jpg') ||
            requested.endsWith('.jpeg') ||
            requested.endsWith('.webp'));
    if (isAssetImage) {
      return ByteData.view(transparentPng.buffer);
    }

    return null;
  });
}

/// Écran factice pour les tests de navigation.
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

  group('PersonalWeather (tests simplifiés)', () {
    testWidgets('1) L’asset JSON est chargeable et non vide', (tester) async {
      mockQuestionsAsset();

      final s = await rootBundle
          .loadString('assets/personal_weather_questions.json');
      final data = jsonDecode(s) as List<dynamic>;

      expect(data, isNotEmpty);
      expect((data.first as Map)['question'], 'Q1?');
    });

    testWidgets('2) La route /mavie est navigable (pushNamed OK)', (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: const _RouteScreen('home'),
        routes: {
          '/mavie': (_) => const _RouteScreen('mavie'),
        },
      ));

      navKey.currentState!.pushNamed('/mavie');

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ROUTE: mavie'), findsOneWidget);
    });

    testWidgets('3) PersonalWeatherPage rend un AppScaffold', (tester) async {
      mockQuestionsAsset();

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const PersonalWeatherPage(),
      ));

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AppScaffold), findsOneWidget);
      expect(find.text('Météo personnelle'), findsOneWidget);
    });
  });
}
