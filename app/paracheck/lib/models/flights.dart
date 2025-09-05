class Flight {
  String date; // Exemple : '12 août 2025'
  String duration; // Exemple : '1h45'
  int altitude; // En mètres

  Flight({
    required this.date,
    required this.duration,
    required this.altitude,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'duration': duration,
        'altitude': altitude,
      };

  factory Flight.fromJson(Map<String, dynamic> json) => Flight(
        date: json['date'],
        duration: json['duration'],
        altitude: json['altitude'],
      );
}

// Quelques exemples de vols en dur
final List<Flight> sampleFlights = [
  Flight(date: '12 août 2025', duration: '1h45', altitude: 1200),
  Flight(date: '5 août 2025', duration: '1h10', altitude: 950),
  Flight(date: '28 juillet 2025', duration: '2h00', altitude: 1400),
];