/*
 * flight_repository.dart
 * ----------------------
 * This file defines the FlightRepository interface for managing flights and their data,
 * and provides a SharedPrefsFlightRepository implementation using SharedPreferences for local storage.
 * Flights are stored as a JSON-encoded list in SharedPreferences.
 */
import 'dart:convert';

import 'package:paracheck/models/flights.dart';
import 'package:paracheck/models/radar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Abstract repository interface for flight data
abstract class FlightRepository {
  Future<List<Flight>> getAll();
  Future<void> add(Flight flight);
  Future<void> removeAt(int index);
  Future<void> clear();
  Future<void> replaceAll(List<Flight> flights);
  Future<Flight?> getById(String id);
  Future<void> finalizeRadar(String id, Radar radar);
}

// Implementation using SharedPreferences for local storage
class SharedPrefsFlightRepository implements FlightRepository {
  static const _key = 'flights_v1';

  // Helper to get SharedPreferences instance
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
    // Sort by date descending
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> add(Flight flight) async {
    final prefs = await _prefs;
    final current = await getAll();
    current.insert(0, flight); // Add at the beginning
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
      throw StateError('Flight not found');
    }
    if (list[i].radar != null) {
      throw StateError('Flight already evaluated');
    }
    list[i] = list[i].copyWith(radar: radar);
    await prefs.setString(
      _key,
      jsonEncode(list.map((f) => f.toJson()).toList()),
    );
  }
}
