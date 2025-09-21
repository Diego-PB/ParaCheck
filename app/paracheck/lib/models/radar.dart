import 'dart:convert';

/// Liste des compétences (doit rester synchronisée avec la page qui affiche le radar)
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

/// Descriptions associées (source de vérité unique)
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

/// Modèle représentant une "Rose des compétences" pour un vol.
class Radar {
  final Map<String, double> scores; // 0..20.0

  const Radar({required this.scores});

  Map<String, dynamic> toJson() => {'scores': scores};

  factory Radar.fromJson(Map<String, dynamic> json) {
    final rawScores = Map<String, dynamic>.from(json['scores'] as Map);
    return Radar(
      scores: rawScores.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Radar.fromJsonString(String s) =>
      Radar.fromJson(jsonDecode(s) as Map<String, dynamic>);

  double average() =>
      scores.isEmpty
          ? 0.0
          : scores.values.reduce((a, b) => a + b) / scores.length;

  /// Récupère la valeur pour une feature, 0.0 par défaut si absente
  double scoreOf(String feature) => scores[feature] ?? 0.0;

  /// Retourne la liste des scores ordonnée selon `featuresOrder`.
  /// Utile pour alimenter un RadarChart.
  List<double> toOrderedList(List<String> order) => order.map(scoreOf).toList();

  /// Normalise les scores pour qu'elles contiennent au moins toutes les clés requises
  Map<String, double> normalizedScores(List<String> required) {
    final out = <String, double>{};
    for (final f in required) {
      out[f] = scoreOf(f);
    }
    for (final k in scores.keys) {
      out.putIfAbsent(k, () => scores[k]!);
    }
    return out;
  }

  /// Récupère la description (vide si introuvable)
  String descriptionFor(String feature) => radarDescriptions[feature] ?? '';
}
