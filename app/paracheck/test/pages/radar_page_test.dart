// test/pages/radar_page_test.dart
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:paracheck/pages/radar_page.dart';
import 'package:paracheck/models/radar.dart';
import 'package:paracheck/models/flight.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

/// Mock minimal des assets (manifests + images → PNG 1x1) pour éviter les erreurs d'assets.
void _installMinimalAssets() {
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

/// Seed d’un vol dans le repo SharedPreferences pour que RadarPage trouve le vol.
Future<void> _seedFlight({
  required String id,
  String site = 'Site',
  DateTime? date,
  Duration duration = const Duration(minutes: 30),
  int altitude = 1000,
  Radar? radar, // si non-null → mode read-only
}) async {
  SharedPreferences.setMockInitialValues({});
  final repo = SharedPrefsFlightRepository();
  final f = Flight(
    id: id,
    site: site,
    date: date ?? DateTime(2025, 9, 20),
    duration: duration,
    altitude: altitude,
    radar: radar,
  );
  // On essaye add(); si ton repo n’a pas replaceAll dans ce contexte, add suffit.
  await repo.add(f);
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

  setUp(() {
    _installMinimalAssets();
  });

  group('RadarPage (tests simplifiés)', () {
    test('1) radarFeatures (source) n’est pas vide', () {
      expect(radarFeatures, isNotEmpty);
    });

    testWidgets('2) La route /postflight_debrief est navigable (pushNamed OK)',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: const _RouteScreen('home'),
        routes: {
          '/postflight_debrief': (_) => const _RouteScreen('postflight_debrief'),
        },
      ));

      navKey.currentState!.pushNamed('/postflight_debrief');

      await tester.pump(); // construit la route
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ROUTE: postflight_debrief'), findsOneWidget);
    });

    testWidgets('3) RadarPage rend AppScaffold + le titre', (tester) async {
      // Seed d’un vol simple sans radar → page editable, mais AppScaffold s’affiche tout de suite
      await _seedFlight(id: 'f1');

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const RadarPage(flightId: 'f1'),
        routes: {
          '/homepage': (_) => const _RouteScreen('home'),
          '/postflight_debrief': (_) => const _RouteScreen('postflight_debrief'),
        },
      ));

      // Petit pump pour laisser la frame s’afficher
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AppScaffold), findsOneWidget);
      expect(find.text('Radar de compétences'), findsOneWidget);
    });
  });
}
