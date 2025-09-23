import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/models/flight.dart';

void main() {
  test('Flight toJson/fromJson conserve les champs principaux', () {
    final f = Flight(
      id: 'id-123',
      site: 'Organya',
      date: DateTime(2025, 9, 21, 14, 30),
      duration: const Duration(hours: 1, minutes: 45),
      altitude: 1550,
    );

    final map = f.toJson();
    expect(map['id'], 'id-123');
    expect(map['site'], 'Organya');
    expect(map['duration_sec'], 6300); // 1h45 => 105 min => 6300 s
    expect(map['altitude_m'], 1550);

    final back = Flight.fromJson(Map<String, dynamic>.from(map));
    expect(back.id, 'id-123');
    expect(back.site, 'Organya');
    expect(back.date.toIso8601String(), f.date.toIso8601String());
    expect(back.duration, const Duration(hours: 1, minutes: 45));
    expect(back.altitude, 1550);

    // Formats utilitaires
    expect(f.formatDuration(const Duration(hours: 2, minutes: 3)), '2h 3m');
  });
}
