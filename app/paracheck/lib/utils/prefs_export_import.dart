// lib/utils/prefs_export_import.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

/// Export/Import de SharedPreferences en JSON typé.
/// Format:
/// {
///   "app": "paracheck",
///   "schema": 1,
///   "exportedAt": "2025-09-24T00:00:00.000Z",
///   "data": {
///     "key": {"t":"string"|"int"|"double"|"bool"|"stringList", "v": ...}
///   }
/// }
class PrefsExportImport {
  static const int schemaVersion = 1;

  /// Export -> String JSON (utilisé par exportAsBytes).
  static Future<String> exportAsString({String? prefix}) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final Map<String, Map<String, dynamic>> data = {};

    for (final k in keys) {
      if (prefix != null && !k.startsWith(prefix)) continue;

      final v = prefs.get(k); // <- évite les casts foireux
      if (v is String) {
        data[k] = {"t": "string", "v": v};
      } else if (v is int) {
        data[k] = {"t": "int", "v": v};
      } else if (v is double) {
        data[k] = {"t": "double", "v": v};
      } else if (v is bool) {
        data[k] = {"t": "bool", "v": v};
      } else if (v is List<String>) {
        data[k] = {"t": "stringList", "v": v};
      } else {
        // Type inconnu (ne devrait pas arriver avec SharedPreferences)
        // On ignore proprement.
      }
    }

    final root = <String, dynamic>{
      "app": "paracheck",
      "schema": schemaVersion,
      "exportedAt": DateTime.now().toUtc().toIso8601String(),
      "data": data,
    };

    return const JsonEncoder.withIndent('  ').convert(root);
  }

  /// Export -> bytes (.json)
  static Future<Uint8List> exportAsBytes({String? prefix}) async {
    final json = await exportAsString(prefix: prefix);
    return Uint8List.fromList(utf8.encode(json));
  }

  /// Import depuis String JSON.
  static Future<int> importFromString(
    String json, {
    bool clearBefore = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    late final Map<String, dynamic> root;
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) {
      root = decoded;
    } else {
      throw const FormatException("JSON racine invalide (attendu: objet).");
    }

    // Accepte format typé (root["data"]) ou plat (fallback)
    Map<String, dynamic> payload;
    final dataNode = root["data"];
    if (dataNode is Map<String, dynamic>) {
      payload = dataNode;
    } else {
      payload = root; // fallback
    }

    if (clearBefore) {
      await prefs.clear();
    }

    int written = 0;

    for (final entry in payload.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map && value.containsKey("t")) {
        final type = value["t"];
        final v = value["v"];
        switch (type) {
          case "string":
            await prefs.setString(key, (v ?? "").toString());
            written++;
            break;
          case "int":
            if (v is num) {
              await prefs.setInt(key, v.toInt());
              written++;
            }
            break;
          case "double":
            if (v is num) {
              await prefs.setDouble(key, v.toDouble());
              written++;
            }
            break;
          case "bool":
            if (v is bool) {
              await prefs.setBool(key, v);
              written++;
            }
            break;
          case "stringList":
            if (v is List) {
              await prefs.setStringList(
                key,
                List<String>.from(v.map((e) => e.toString())),
              );
              written++;
            }
            break;
          default:
            // inconnu -> ignore
            break;
        }
      } else {
        // Fallback: JSON plat, on infère
        final v = value;
        if (v is bool) {
          await prefs.setBool(key, v);
          written++;
        } else if (v is int) {
          await prefs.setInt(key, v);
          written++;
        } else if (v is double) {
          await prefs.setDouble(key, v);
          written++;
        } else if (v is String) {
          await prefs.setString(key, v);
          written++;
        } else if (v is List) {
          await prefs.setStringList(
            key,
            List<String>.from(v.map((e) => e.toString())),
          );
          written++;
        }
      }
    }

    return written;
  }

  /// Import depuis bytes (.json)
  static Future<int> importFromBytes(
    Uint8List bytes, {
    bool clearBefore = false,
  }) {
    return importFromString(utf8.decode(bytes), clearBefore: clearBefore);
  }
}
