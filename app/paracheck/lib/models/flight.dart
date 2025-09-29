/*
 Flight model represents a paragliding flight record in the ParaCheck application
 This model stores essential flight information including location, date, duration,
 altitude, and optional radar data and debrief entries. It provides serialization
 capabilities to/from JSON for data persistence and includes utility methods
 for formatting date and duration display.
*/

import 'package:paracheck/models/debrief.dart';
import 'package:paracheck/models/radar.dart';

class Flight {
  final String id;           // Unique identifier for the flight
  final String site;         // Flight site name (e.g., 'Site de vol')
  final DateTime date;       // Flight date (e.g., '12 août 2025')
  final Duration duration;   // Flight duration (e.g., '1h45')
  final int altitude;        // Maximum altitude reached in meters
  final Radar? radar;        // Optional radar evaluation data
  final List<DebriefEntry> debrief; // Post-flight debrief entries

  const Flight({
    required this.id,
    required this.site,
    required this.date,
    required this.duration,
    required this.altitude,
    this.radar,
    this.debrief = const [],
  });

  // Creates a copy of the flight with optionally updated fields
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

  // Converts flight data to JSON format for persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'site': site,
    'date': date.toIso8601String(),
    'duration_sec': duration.inSeconds,        // Store duration as seconds
    'altitude_m': altitude,                    // Store altitude in meters
    if (radar != null) 'radar': radar!.toJson(),
    if (debrief.isNotEmpty) 'debrief': debrief.map((e) => e.toJson()).toList(),
  };

  // Creates a Flight instance from JSON data
  factory Flight.fromJson(Map<String, dynamic> json) {
    final r = json['radar'];
    final d = (json['debrief'] as List?) ?? const [];
    return Flight(
      id: (json['id'] as String?) ??
          // Generate fallback ID from date timestamp and site hash if missing
          '${DateTime.parse(json['date'] as String).millisecondsSinceEpoch}_${(json['site'] ?? '').hashCode}',
      site: json['site'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: (json['duration_sec'] as num).toInt()),
      altitude: (json['altitude_m'] as num).toInt(),
      radar: r == null ? null : Radar.fromJson(Map<String, dynamic>.from(r)),
      debrief: d
          .map((e) => DebriefEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  // Formats date as DD/MM/YYYY for display
  String formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  // Formats duration as "Xh Ym" for display
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
