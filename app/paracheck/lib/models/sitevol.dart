/*
 * sitevol.dart
 * -------------
 * Data model representing a saved flight site with basic metadata.
 * Includes JSON serialization helpers for SharedPreferences storage.
 */

class SiteVol {
  final String id; // Stable identifier for the site entry
  final String name; // Display name of the site
  final DateTime createdAt; // When this entry was created
  final DateTime? lastUsedAt; // Last time it was used (optional)
  final int useCount; // Times used (optional utility metric)

  const SiteVol({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
    this.useCount = 0,
  });

  SiteVol copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? useCount,
  }) {
    return SiteVol(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    if (lastUsedAt != null) 'lastUsedAt': lastUsedAt!.toIso8601String(),
    'useCount': useCount,
  };

  factory SiteVol.fromJson(Map<String, dynamic> json) {
    return SiteVol(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt:
          json['lastUsedAt'] == null
              ? null
              : DateTime.parse(json['lastUsedAt'] as String),
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
    );
  }

  // Convenience factory when only a name is available.
  factory SiteVol.fromName(String name) {
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}_${name.hashCode}';
    return SiteVol(id: id, name: name.trim(), createdAt: now);
  }
}
