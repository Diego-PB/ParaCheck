/*
 * site_repository.dart
 * ---------------------
 * Repository to manage saved flight sites in SharedPreferences.
 * Now stores a JSON-encoded list of SiteVol models, with a migration path
 * from the older simple String list format.
 */
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paracheck/models/sitevol.dart';

abstract class SiteRepository {
  // Model-based API
  Future<List<SiteVol>> getAll();
  Future<void> addName(String siteName); // add if not exists (case-insensitive)
  Future<void> add(SiteVol site);
  Future<void> removeAt(int index);
  Future<void> removeById(String id);
  Future<void> removeByName(String siteName);
  Future<void> renameByName(String oldValue, String newValue);
  Future<void> renameById(String id, String newValue);
  Future<void> replaceAll(List<SiteVol> sites);
  Future<void> clear();

  // Convenience helpers
  Future<List<String>> getAllNames() async =>
      (await getAll()).map((e) => e.name).toList();
}

class SharedPrefsSiteRepository implements SiteRepository {
  static const _keyStrings = 'sites_v1'; // legacy string list key
  static const _keyModels = 'sites_v2'; // new models list key

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  String _normalize(String s) => s.trim();
  bool _eq(String a, String b) => a.toLowerCase() == b.toLowerCase();

  @override
  Future<List<SiteVol>> getAll() async {
    final prefs = await _prefs;
    final jsonList = prefs.getString(_keyModels);
    if (jsonList != null && jsonList.isNotEmpty) {
      final list =
          (jsonDecode(jsonList) as List)
              .map((e) => SiteVol.fromJson(Map<String, dynamic>.from(e)))
              .toList();
      return list;
    }
    // Try migrating from legacy string list format
    final legacy = prefs.getStringList(_keyStrings);
    if (legacy != null && legacy.isNotEmpty) {
      final migrated =
          legacy
              .map((name) => _normalize(name))
              .where((name) => name.isNotEmpty)
              .toSet()
              .map((name) => SiteVol.fromName(name))
              .toList();
      await _save(migrated);
      // Remove legacy key to avoid ambiguity
      await prefs.remove(_keyStrings);
      return migrated;
    }
    return <SiteVol>[];
  }

  Future<void> _save(List<SiteVol> sites) async {
    final prefs = await _prefs;
    await prefs.setString(
      _keyModels,
      jsonEncode(sites.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> addName(String siteName) async {
    final v = _normalize(siteName);
    if (v.isEmpty) return;
    final list = await getAll();
    final exists = list.any((s) => _eq(s.name, v));
    if (!exists) {
      list.insert(0, SiteVol.fromName(v));
      await _save(list);
    }
  }

  @override
  Future<void> add(SiteVol site) async {
    final v = site.name.trim();
    if (v.isEmpty) return;
    final list = await getAll();
    if (list.any((s) => _eq(s.name, v))) return;
    list.insert(0, site);
    await _save(list);
  }

  @override
  Future<void> removeAt(int index) async {
    final list = await getAll();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await _save(list);
  }

  @override
  Future<void> removeById(String id) async {
    final list = await getAll();
    list.removeWhere((s) => s.id == id);
    await _save(list);
  }

  @override
  Future<void> removeByName(String siteName) async {
    final list = await getAll();
    list.removeWhere((s) => _eq(s.name, siteName));
    await _save(list);
  }

  @override
  Future<void> renameByName(String oldValue, String newValue) async {
    final nv = _normalize(newValue);
    if (nv.isEmpty) return;
    final list = await getAll();
    final idx = list.indexWhere((s) => _eq(s.name, oldValue));
    if (idx == -1) return;
    // If renaming collides with other existing value, de-duplicate by removing old
    if (list.any((s) => _eq(s.name, nv))) {
      list.removeAt(idx);
    } else {
      list[idx] = list[idx].copyWith(name: nv);
    }
    await _save(list);
  }

  @override
  Future<void> renameById(String id, String newValue) async {
    final nv = _normalize(newValue);
    if (nv.isEmpty) return;
    final list = await getAll();
    final idx = list.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    if (list.any((s) => _eq(s.name, nv))) {
      list.removeAt(idx);
    } else {
      list[idx] = list[idx].copyWith(name: nv);
    }
    await _save(list);
  }

  @override
  Future<void> replaceAll(List<SiteVol> sites) async {
    // Normalize and de-duplicate by name (case-insensitive)
    final out = <SiteVol>[];
    for (final s in sites) {
      final v = _normalize(s.name);
      if (v.isEmpty) continue;
      if (!out.any((e) => _eq(e.name, v))) {
        out.add(s.copyWith(name: v));
      }
    }
    await _save(out);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_keyModels);
    await prefs.remove(_keyStrings); // also clear legacy
  }

  @override
  Future<List<String>> getAllNames() async {
    final all = await getAll();
    return all.map((e) => e.name).toList();
  }
}
