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

String formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
