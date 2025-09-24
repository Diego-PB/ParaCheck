import 'dart:convert';
/// List of skills (must stay synchronized with the page that displays the radar)
/// Each entry combines a short code and a human label separated by ' - '.
const List<String> radarFeatures = [
  "PIL - Pilotage",
  "SIV - Situation Incidents de Vol",
  "AIR - Aérologie et météorologie",
  "CNS - Connaissances et règles",
  "MAT - Matériel",
  "ENV - Environnement et communauté",
  "DEC - Décisions",
  "STS - Gestion du stress",
  "GES - Gestion du vol",
  "COS - Conscience de la situation",
  "PHY - Physique et physiologie",
];

/// Associated descriptions (single source of truth)
/// Keys must match the entries in [radarFeatures]. These text blocks are used
/// to show explanatory help for each skill in the UI.
const Map<String, String> radarDescriptions = {
  "PIL - Pilotage":
      "Plan de vol. Gonflage et maîtrise au sol. Utilisation commandes et sellette. Technique adaptée de décollage, approche et atterrissage.",
  "SIV - Situation Incidents de Vol":
      "Le domaine de vol. Limites en tangage et roulis. Procédures d’urgence et secours. Effets de la sidération. Parachute de secours.",
  "AIR - Aérologie et météorologie":
      "Écoulements, pièges. Maîtrise de notre élément.",
  "CNS - Connaissances et règles":
      "Théorie du vol, réglementations, recommandations, documentations, brevets, responsabilités, accidentologie.",
  "MAT - Matériel":
      "Fonctionnement et utilisation. Vieillissement, soin, pliage, contrôle. Recommandations fédérales. Manuel de vol. Homologation.",
  "ENV - Environnement et communauté":
      "Liens à la communauté (information, intégration, résilience). Impacts environnementaux et préservation. Vigilance en vol (anticollision).",
  "DEC - Décisions":
      "Procédures et Check-List pour la décision. Les biais. Remise en cause des décisions (Plan B).",
  "STS - Gestion du stress":
      "Ressentis, mécanismes du stress. Effets du stress dont sidération. Prise en compte et régulation.",
  "GES - Gestion du vol":
      "Objectifs du vol. Choix de créneaux. Tâches récurrentes. Suivi du vol. Menaces, erreurs, parades. Débriefing et auto-débriefing.",
  "COS - Conscience de la situation":
      "Préparation du vol. Prise d’informations : analyse, anticipation. Identification des menaces. Pièges cumulatifs, biais.",
  "PHY - Physique et physiologie":
      "Forme physique et psychologique. Fatigue. Échauffement et concentration. Protection solaire, hydratation et alimentation.",
};

/// Model representing a "skills rose" for a flight.
/// The model stores a map of scores (0..20) for each skill and provides
/// convenient serialization, utility methods and normalization helpers.
class Radar {
  final Map<String, double> scores; // values expected between 0 and 20

  const Radar({required this.scores});
  /// Convert to a JSON-compatible map.
  Map<String, dynamic> toJson() => {'scores': scores};

  /// Construct a Radar from a decoded JSON map.
 /// The method defensively casts numeric values to double.
  factory Radar.fromJson(Map<String, dynamic> json) {
    final rawScores = Map<String, dynamic>.from(json['scores'] as Map);
    return Radar(
      scores: rawScores.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }
  /// Convenience: encode to a JSON string.
  String toJsonString() => jsonEncode(toJson());
  /// Convenience: decode from a JSON string.
  factory Radar.fromJsonString(String s) =>
      Radar.fromJson(jsonDecode(s) as Map<String, dynamic>);
  /// Compute the arithmetic average of all recorded scores.
  /// Returns 0.0 when the map is empty to avoid division by zero.
  double average() =>
      scores.isEmpty
          ? 0.0
          : scores.values.reduce((a, b) => a + b) / scores.length;

  /// Get the score for a single feature; returns 0.0 if the key is absent.
  double scoreOf(String feature) => scores[feature] ?? 0.0;

  /// Return the scores ordered according to [order].
  /// This is useful to feed plotting widgets that require a specific order.
  List<double> toOrderedList(List<String> order) => order.map(scoreOf).toList();

  /// Normalize the stored scores so that the returned map contains at least
  /// all keys present in [required]. Missing keys are filled with 0.0.
  /// Any additional keys present in the original map are preserved.
  Map<String, double> normalizedScores(List<String> required) {
    final out = <String, double>{};
    for (final f in required) {
      out[f] = scoreOf(f);
    }
    // Preserve any extra keys that were present in the original map
    for (final k in scores.keys) {
      out.putIfAbsent(k, () => scores[k]!);
    }
    return out;
  }

  /// Retrieve the human-readable description for a feature.
  /// Returns an empty string when the feature is unknown.
  String descriptionFor(String feature) => radarDescriptions[feature] ?? '';
}
