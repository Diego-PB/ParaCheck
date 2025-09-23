import 'package:paracheck/models/debrief.dart';
import 'package:paracheck/models/radar.dart';

class Flight {
  final String id;
  final String site; // Exemple : 'Site de vol'
  final DateTime date; // Exemple : '12 août 2025'
  final Duration duration; // Exemple : '1h45'
  final int altitude; // En mètres
  final Radar? radar; // Peut être null si pas encore évalué
  final List<DebriefEntry> debrief;

  const Flight({
    required this.id,
    required this.site,
    required this.date,
    required this.duration,
    required this.altitude,
    this.radar,
    this.debrief = const [],
  });

  Flight copyWith({
    String? id,
    String? site,
    DateTime? date,
    Duration? duration,
    int? altitude,
    Radar? radar,
    List<DebriefEntry>? debrief,
  }) {
    return Flight(
      id: id ?? this.id,
      site: site ?? this.site,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      altitude: altitude ?? this.altitude,
      radar: radar ?? this.radar,
      debrief: debrief ?? this.debrief,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'site': site,
    'date': date.toIso8601String(),
    'duration_sec': duration.inSeconds,
    'altitude_m': altitude,
    if (radar != null) 'radar': radar!.toJson(),
    if (debrief.isNotEmpty) 'debrief': debrief.map((e) => e.toJson()).toList(),
  };

  factory Flight.fromJson(Map<String, dynamic> json) {
    final r = json['radar'];
    final d = (json['debrief'] as List?) ?? const [];
    return Flight(
      id:
          (json['id'] as String?) ??
          '${DateTime.parse(json['date'] as String).millisecondsSinceEpoch}_${(json['site'] ?? '').hashCode}',
      site: json['site'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: (json['duration_sec'] as num).toInt()),
      altitude: (json['altitude_m'] as num).toInt(),
      radar: r == null ? null : Radar.fromJson(Map<String, dynamic>.from(r)),
      debrief:
          d
              .map((e) => DebriefEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
  }

  String formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
