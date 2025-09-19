import 'dart:convert';

import 'package:paracheck/models/radar_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository abstrait pour gérer la persistance des "Rose".
/// Même patron que le `FlightRepository` que ton ami a créé.
abstract class RoseRepository {
  Future<List<Rose>> getAll();
  Future<void> add(Rose rose);
  Future<void> removeAt(int index);
  Future<void> clear();
  Future<void> replaceAll(List<Rose> roses);
}

class SharedPrefsRoseRepository implements RoseRepository {
  static const _key = 'roses_v1';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  @override
  Future<List<Rose>> getAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final list = (jsonDecode(raw) as List)
        .map((e) => Rose.fromJson(e as Map<String, dynamic>))
        .toList();

    // Pas de date dans Rose par défaut — on retourne l'ordre stocké (ajout en tête).
    return list;
  }

  @override
  Future<void> add(Rose rose) async {
    final prefs = await _prefs;
    final current = await getAll();
    current.insert(0, rose); // ajout en tête
    final encoded = jsonEncode(current.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  @override
  Future<void> removeAt(int index) async {
    final prefs = await _prefs;
    final current = await getAll();
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    final encoded = jsonEncode(current.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }

  @override
  Future<void> replaceAll(List<Rose> roses) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(roses.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
