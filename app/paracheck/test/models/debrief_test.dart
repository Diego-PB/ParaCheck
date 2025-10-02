import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/models/debrief.dart';

void main() {
  group('DebriefEntry', () {
    test('toJson produit la map attendue', () {
      final entry = DebriefEntry(label: 'Météo', value: 'Stable');
      expect(entry.toJson(), {'label': 'Météo', 'value': 'Stable'});
    });

    test('fromJson reconstruit correctement l’objet', () {
      final json = {'label': 'Décollage', 'value': 'Face voile'};
      final entry = DebriefEntry.fromJson(Map<String, dynamic>.from(json));
      expect(entry.label, 'Décollage');
      expect(entry.value, 'Face voile');
    });

    test('round-trip JSON (unique entrée)', () {
      final original = DebriefEntry(label: 'Site', value: 'Annecy');
      final s = jsonEncode(original.toJson());
      final decoded =
          DebriefEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
      expect(decoded.label, original.label);
      expect(decoded.value, original.value);
    });

    test('round-trip JSON (liste d’entrées)', () {
      final list = [
        DebriefEntry(label: 'Objectif', value: 'Plein air'),
        DebriefEntry(label: 'Durée', value: '00:25'),
      ];

      final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      final decoded = (jsonDecode(encoded) as List)
          .map((m) => DebriefEntry.fromJson(m as Map<String, dynamic>))
          .toList();

      expect(decoded.length, 2);
      expect(decoded[0].label, 'Objectif');
      expect(decoded[0].value, 'Plein air');
      expect(decoded[1].label, 'Durée');
      expect(decoded[1].value, '00:25');
    });

    test('fromJson lève une erreur si types invalides', () {
      // label non-string
      expect(
        () => DebriefEntry.fromJson({'label': 123, 'value': 'ok'}),
        throwsA(isA<TypeError>()),
      );
      // value non-string
      expect(
        () => DebriefEntry.fromJson({'label': 'ok', 'value': false}),
        throwsA(isA<TypeError>()),
      );
      // clés manquantes
      expect(
        () => DebriefEntry.fromJson({'label': 'ok'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
