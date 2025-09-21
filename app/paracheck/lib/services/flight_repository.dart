import 'dart:convert';

import 'package:paracheck/models/flights.dart';
import 'package:paracheck/models/radar.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FlightRepository {
  Future<List<Flight>> getAll();
  Future<void> add(Flight flight);
  Future<void> removeAt(int index);
  Future<void> clear();
  Future<void> replaceAll(List<Flight> flights);
  Future<Flight?> getById(String id);
  Future<void> finalizeRadar(String id, Radar radar);
}

class SharedPrefsFlightRepository implements FlightRepository {
  static const _key = 'flights_v1';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  @override
  Future<List<Flight>> getAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list =
        (jsonDecode(raw) as List)
            .map((e) => Flight.fromJson(e as Map<String, dynamic>))
            .toList();
    // tri par date décroissante
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> add(Flight flight) async {
    final prefs = await _prefs;
    final current = await getAll();
    current.insert(0, flight); // Ajout en tête
    final encoded = jsonEncode(current.map((f) => f.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  @override
  Future<void> removeAt(int index) async {
    final prefs = await _prefs;
    final current = await getAll();
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    final encoded = jsonEncode(current.map((f) => f.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }

  @override
  Future<void> replaceAll(List<Flight> flights) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(flights.map((f) => f.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  @override
  Future<Flight?> getById(String id) async {
    final all = await getAll();
    for (final f in all) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Future<void> finalizeRadar(String id, Radar radar) async {
    final prefs = await _prefs;
    final list = await getAll();
    final i = list.indexWhere((f) => f.id == id);
    if (i == -1) {
      throw StateError('Vol introuvable');
    }
    if (list[i].radar != null) {
      throw StateError('Vol déjà évalué');
    }
    list[i] = list[i].copyWith(radar: radar);
    await prefs.setString(
      _key,
      jsonEncode(list.map((f) => f.toJson()).toList()),
    );
  }
}
