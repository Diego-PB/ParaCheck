class Flight {
  final String site; // Exemple : 'Site de vol'
  final DateTime date; // Exemple : '12 août 2025'
  final Duration duration; // Exemple : '1h45'
  final int altitude; // En mètres

  const Flight({
    required this.site,
    required this.date,
    required this.duration,
    required this.altitude,
  });

  Flight copyWith({
    String? site,
    DateTime? date,
    Duration? duration,
    int? altitude,
  }) {
    return Flight(
      site: site ?? this.site,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      altitude: altitude ?? this.altitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'site': site,
        'date': date.toIso8601String(),
        'duration_sec': duration.inSeconds,
        'altitude_m': altitude,
      };

  factory Flight.fromJson(Map<String, dynamic> json) => Flight(
        site: json['site'] as String,
        date: DateTime.parse(json['date'] as String),
        duration: Duration(seconds: (json['duration_sec'] as num).toInt()),
        altitude: (json['altitude_m'] as num).toInt(),
      );
}

// Quelques exemples de vols en dur
final List<Flight> sampleFlights = [
  Flight(site: 'Site de vol A', date: DateTime(2025, 8, 12), duration: Duration(hours: 1, minutes: 45), altitude: 1200),
  Flight(site: 'Site de vol B', date: DateTime(2025, 8, 5), duration: Duration(hours: 1, minutes: 10), altitude: 950),
  Flight(site: 'Site de vol C', date: DateTime(2025, 7, 28), duration: Duration(hours: 2), altitude: 1400),
];