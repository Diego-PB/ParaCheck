import 'package:paracheck/models/radar.dart';

class Flight {
  final String id;
  final String site; // Exemple : 'Site de vol'
  final DateTime date; // Exemple : '12 août 2025'
  final Duration duration; // Exemple : '1h45'
  final int altitude; // En mètres
  final Radar? radar; // Peut être null si pas encore évalué

  const Flight({
    required this.id,
    required this.site,
    required this.date,
    required this.duration,
    required this.altitude,
    this.radar,
  });

  Flight copyWith({
    String? id,
    String? site,
    DateTime? date,
    Duration? duration,
    int? altitude,
    Radar? radar,
  }) {
    return Flight(
      id: id ?? this.id,
      site: site ?? this.site,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      altitude: altitude ?? this.altitude,
      radar: radar ?? this.radar,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'site': site,
    'date': date.toIso8601String(),
    'duration_sec': duration.inSeconds,
    'altitude_m': altitude,
    if (radar != null) 'radar': radar!.toJson(),
  };

  factory Flight.fromJson(Map<String, dynamic> json) {
    final r = json['radar'];
    return Flight(
      id:
          (json['id'] as String?) ??
          '${DateTime.parse(json['date'] as String).millisecondsSinceEpoch}_${(json['site'] ?? '').hashCode}',
      site: json['site'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: (json['duration_sec'] as num).toInt()),
      altitude: (json['altitude_m'] as num).toInt(),
      radar: r == null ? null : Radar.fromJson(Map<String, dynamic>.from(r)),
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
