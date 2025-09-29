/*
 DebriefEntry model represents a single entry in a post-flight debrief for ParaCheck.
 This simple model stores a label-value pair (e.g., "Weather conditions" -> "Light wind").
 It provides JSON serialization for data persistence and is used to build
 structured post-flight evaluation records.
*/

class DebriefEntry {
  final String label;  // The category or question label (e.g., "Weather conditions")
  final String value;  // The corresponding answer or observation

  DebriefEntry({required this.label, required this.value});

  // Converts the debrief entry to JSON format for storage
  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  // Creates a DebriefEntry from JSON data
  factory DebriefEntry.fromJson(Map<String, dynamic> json) => DebriefEntry(
    label: json['label'] as String,
    value: json['value'] as String,
  );
}
