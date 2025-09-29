/*
 * site_repository.dart
 * ---------------------
 * Simple repository to manage saved flight sites (strings) in SharedPreferences.
 * Provides CRUD operations and case-insensitive de-duplication.
 */
import 'package:shared_preferences/shared_preferences.dart';

abstract class SiteRepository {
  Future<List<String>> getAll();
  Future<void> add(String site); // add if not exists (case-insensitive)
  Future<void> removeAt(int index);
  Future<void> remove(String site);
  Future<void> rename(String oldValue, String newValue);
  Future<void> replaceAll(List<String> sites);
  Future<void> clear();
}

class SharedPrefsSiteRepository implements SiteRepository {
  static const _key = 'sites_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  String _normalize(String s) => s.trim();
  bool _eq(String a, String b) => a.toLowerCase() == b.toLowerCase();

  @override
  Future<List<String>> getAll() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_key) ?? const <String>[];
    // Return a copy to avoid external mutation
    return List<String>.from(list);
  }

  Future<void> _save(List<String> sites) async {
    final prefs = await _prefs;
    await prefs.setStringList(_key, sites);
  }

  @override
  Future<void> add(String site) async {
    final v = _normalize(site);
    if (v.isEmpty) return;
    final list = await getAll();
    final exists = list.any((s) => _eq(s, v));
    if (!exists) {
      list.insert(0, v);
      await _save(list);
    }
  }

  @override
  Future<void> removeAt(int index) async {
    final list = await getAll();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await _save(list);
  }

  @override
  Future<void> remove(String site) async {
    final list = await getAll();
    list.removeWhere((s) => _eq(s, site));
    await _save(list);
  }

  @override
  Future<void> rename(String oldValue, String newValue) async {
    final nv = _normalize(newValue);
    if (nv.isEmpty) return;
    final list = await getAll();
    final idx = list.indexWhere((s) => _eq(s, oldValue));
    if (idx == -1) return;
    // If renaming collides with other existing value, de-duplicate by removing old
    if (list.any((s) => _eq(s, nv))) {
      list.removeAt(idx);
    } else {
      list[idx] = nv;
    }
    await _save(list);
  }

  @override
  Future<void> replaceAll(List<String> sites) async {
    final cleaned = <String>[];
    for (final s in sites) {
      final v = _normalize(s);
      if (v.isEmpty) continue;
      if (!cleaned.any((e) => _eq(e, v))) {
        cleaned.add(v);
      }
    }
    await _save(cleaned);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
