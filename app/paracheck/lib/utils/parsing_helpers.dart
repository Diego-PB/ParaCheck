DateTime parseDateFr(String input) {
  final s = input.trim();
  // Accepte les formats : 12/08/2025, 12-08-2025, 12.08.2025, 12 08 2025
  final regex = RegExp(r'^(\d{1,2})[\/\-. ](\d{1,2})[\/\-. ](\d{2,4})$');
  final match = regex.firstMatch(s);
  if (match != null) {
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    return DateTime(year, month, day);
  }
  // Fallback : essaie un parse ISO/locale
  return DateTime.parse(s); // Peut lancer une exception si échec
}

// Accepte les formats : "1h30", "1 h 30", "90", "90min", "1:30", "01:30", "45m", "45"
Duration parseDurationFr(String input) {
  var s = input.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  if(s.contains('h')) {
    final parts = s.split('h');
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = parts.length > 1 && parts[1].isNotEmpty ? int.tryParse(parts[1].replaceAll('min', '')) ?? 0 : 0;
    return Duration(hours: hours, minutes: minutes);
  }
  if(s.contains(':')) {
    final parts = s.split(':');
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = parts.length > 1 ? int.tryParse(parts[1].replaceAll('min', '')) ?? 0 : 0;
    return Duration(hours: hours, minutes: minutes);
  }
  // "90min", "90"
  s = s.replaceAll('min', '').replaceAll('m', '');
  final minutes = int.tryParse(s);
  if(minutes != null) {
    return Duration(minutes: minutes);
  }
  throw FormatException('Invalid duration format: $input');
}

// Accepte les formats : "1200", "1200m", "1 200 m", "1.200m"
int parseAltitudeMeters(String input) {
  final s = input.toLowerCase().replaceAll(RegExp(r'[^0-9]'), '');
  if(s.isEmpty) {
    throw FormatException('Invalid altitude format: $input');
  }
  return int.parse(s);
}
