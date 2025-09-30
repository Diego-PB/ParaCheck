// test/pages/postflight_debrief_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:paracheck/pages/postflight_debrief.dart';

/// Mock assets: JSON du formulaire + manifests + images (PNG 1x1)
void _installPostflightAssetMocks({String? payload}) {
  const key = 'assets/postflight_questions.json';
  const defaultJson = '''
[
  {"label":"Site"},
  {"label":"Date"},
  {"label":"Durée"},
  {"label":"Altitude"},
  {"label":"Commentaires"}
]
''';

  final transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  );

  ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) async {
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
    },
  );
}

/// Écran factice pour vérifier les routes
class _RouteScreen extends StatelessWidget {
  final String name;
  const _RouteScreen(this.name, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ROUTE: $name', key: Key('route-$name'))),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock d’assets installé AVANT chaque test
  setUp(() {
    _installPostflightAssetMocks();
  });

  group('PostFlightDebriefPage (tests simplifiés)', () {
    testWidgets('1) L’asset JSON est chargeable et non vide', (tester) async {
      final s = await rootBundle.loadString('assets/postflight_questions.json');
      final data = jsonDecode(s) as List<dynamic>;

      expect(data, isNotEmpty);
      expect((data.first as Map)['label'], 'Site');
    });

    testWidgets('2) La route /radar est navigable (pushNamed OK)', (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const _RouteScreen('home'),
          routes: {'/radar': (_) => const _RouteScreen('radar')},
        ),
      );

      navKey.currentState!.pushNamed('/radar');
      await tester.pump(); // construit la route
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ROUTE: radar'), findsOneWidget);
    });
  });
}
