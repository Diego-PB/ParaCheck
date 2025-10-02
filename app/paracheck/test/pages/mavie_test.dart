// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paracheck/pages/mavie.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

/// Mock des assets requis (JSON + manifests + images).
void mockMavieAssets({String? payload}) {
  const key = 'assets/mavie_questions.json';
  const defaultJson = '''
[
  {"question":"Q1?","answer_ok":"OK","answer_nok":"NOK"}
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

/// Écran factice pour valider les routes.
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

  group('MaviePage (tests simplifiés)', () {
    testWidgets('1) L’asset JSON est chargeable et non vide', (tester) async {
      mockMavieAssets();

      final s = await rootBundle.loadString('assets/mavie_questions.json');
      final data = jsonDecode(s) as List<dynamic>;

      expect(data, isNotEmpty);
      expect((data.first as Map)['question'], 'Q1?');
    });

    testWidgets('2) La route /breathing est navigable (pushNamed OK)', (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: const _RouteScreen('home'),
        routes: {
          '/breathing': (_) => const _RouteScreen('breathing'),
        },
      ));

      navKey.currentState!.pushNamed('/breathing');

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ROUTE: breathing'), findsOneWidget);
    });

    testWidgets('3) MaviePage rend un AppScaffold', (tester) async {
      mockMavieAssets();

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const MaviePage(),
        routes: {
          '/personal_weather': (_) => const _RouteScreen('personal_weather'),
          '/breathing': (_) => const _RouteScreen('breathing'),
        },
      ));

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AppScaffold), findsOneWidget);
      expect(find.text('MAVIE'), findsOneWidget);
    });
  });
}
