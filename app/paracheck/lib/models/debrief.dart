class DebriefEntry {
  final String label;
  final String value;

  DebriefEntry({required this.label, required this.value});

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory DebriefEntry.fromJson(Map<String, dynamic> json) => DebriefEntry(
    label: json['label'] as String,
    value: json['value'] as String,
  );
}
