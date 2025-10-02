import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/models/radar.dart';

void main() {
  group('Radar model', () {
    test('fromJson: cast des int → double', () {
      final json = {
        'scores': {
          'PIL - Pilotage': 10, // int
          'STS - Gestion du stress': 7, // int
        }
      };
      final radar = Radar.fromJson(Map<String, dynamic>.from(json));
      expect(radar.scores['PIL - Pilotage'], 10.0);
      expect(radar.scores['STS - Gestion du stress'], 7.0);
    });

    test('average: 0.0 si vide, sinon moyenne correcte', () {
      expect(const Radar(scores: {}).average(), 0.0);

      final r = Radar(scores: {
        'PIL - Pilotage': 10.0,
        'STS - Gestion du stress': 14.0,
        'AIR - Aérologie et météorologie': 16.0,
      });
      expect(r.average(), closeTo((10.0 + 14.0 + 16.0) / 3.0, 1e-9));
    });

    test('scoreOf: retourne 0.0 si clé absente', () {
      final r = Radar(scores: {
        'PIL - Pilotage': 8.0,
      });
      expect(r.scoreOf('PIL - Pilotage'), 8.0);
      expect(r.scoreOf('STS - Gestion du stress'), 0.0); // manquante
    });

    test('toOrderedList: respecte l’ordre et met 0.0 pour inconnus', () {
      final r = Radar(scores: {
        'PIL - Pilotage': 12.0,
        'STS - Gestion du stress': 6.0,
      });
      final order = [
        'STS - Gestion du stress',
        'PIL - Pilotage',
        'UNKNOWN',
      ];
      final list = r.toOrderedList(order);
      expect(list, [6.0, 12.0, 0.0]);
    });

    test('normalizedScores: remplit les requis manquants et préserve les extras', () {
      final r = Radar(scores: {
        'PIL - Pilotage': 10.0,
        'EXTRA': 3.0,
      });
      final required = [
        'PIL - Pilotage',
        'STS - Gestion du stress',
      ];
      final norm = r.normalizedScores(required);

      // requis présents (avec 0.0 par défaut si manquant)
      expect(norm['PIL - Pilotage'], 10.0);
      expect(norm['STS - Gestion du stress'], 0.0);

      // extra préservé
      expect(norm['EXTRA'], 3.0);

      // rien n’est perdu
      expect(norm.length, 3);
    });

    test('JSON round-trip: toJsonString ↔ fromJsonString', () {
      final original = Radar(scores: {
        'PIL - Pilotage': 11.0,
        'STS - Gestion du stress': 9.0,
      });
      final s = original.toJsonString();
      final decoded = Radar.fromJsonString(s);

      expect(decoded.scores.length, original.scores.length);
      original.scores.forEach((k, v) {
        expect(decoded.scores.containsKey(k), true);
        expect(decoded.scores[k], v);
      });
    });

    test('descriptionFor: connue vs inconnue', () {
      expect(
        Radar(scores: const {}).descriptionFor('PIL - Pilotage'),
        'Plan de vol. Gonflage et maîtrise au sol. Utilisation commandes et sellette. Technique adaptée de décollage, approche et atterrissage.',
      );
      expect(
        Radar(scores: const {}).descriptionFor('UNKNOWN'),
        '',
      );
    });

    test('radarFeatures: cohérence minimale (non vide, contient quelques clés majeures)', () {
      expect(radarFeatures, isNotEmpty);
      expect(radarFeatures.contains('PIL - Pilotage'), true);
      expect(radarFeatures.contains('STS - Gestion du stress'), true);
    });
  });
}
