import 'dart:convert';

/// Liste des compétences (doit rester synchronisée avec la page qui affiche la rose)
const List<String> roseFeatures = [
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
const Map<String, String> roseDescriptions = {
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
class Rose {
  final Map<String, double> scores; // clef = nom de la compétence, valeur = 0.0..20.0

  const Rose({
    required this.scores,
  });

  Rose copyWith({
    Map<String, double>? scores,
  }) {
    return Rose(scores: scores ?? Map<String, double>.from(this.scores));
  }

  Map<String, dynamic> toJson() => {
        'scores': scores.map((k, v) => MapEntry(k, v)),
      };

  factory Rose.fromJson(Map<String, dynamic> json) {
    final rawScores = Map<String, dynamic>.from(json['scores'] as Map);
    final parsedScores =
        rawScores.map((k, v) => MapEntry(k, (v as num).toDouble()));

    return Rose(scores: parsedScores);
  }

  String toJsonString() => jsonEncode(toJson());
  factory Rose.fromJsonString(String s) =>
      Rose.fromJson(jsonDecode(s) as Map<String, dynamic>);

  /// Moyenne simple des scores (0..20)
  double average() {
    if (scores.isEmpty) return 0.0;
    final sum = scores.values.reduce((a, b) => a + b);
    return sum / scores.length;
  }

  /// Récupère la valeur pour une feature, 0.0 par défaut si absente
  double scoreOf(String feature) => scores[feature] ?? 0.0;

  /// Retourne la liste des scores ordonnée selon `featuresOrder`.
  /// Utile pour alimenter un RadarChart.
  List<double> toOrderedList(List<String> featuresOrder) =>
      featuresOrder.map(scoreOf).toList();

  /// Normalise les scores pour qu'elles contiennent au moins toutes les clés requises
  Map<String, double> normalizedScores(List<String> requiredFeatures) {
    final Map<String, double> out = {};
    for (final f in requiredFeatures) {
      out[f] = scoreOf(f);
    }
    // Garde aussi d'éventuelles clés additionnelles présentes dans scores
    for (final k in scores.keys) {
      if (!out.containsKey(k)) out[k] = scores[k]!;
    }
    return out;
  }

  /// Liste des features manquantes par rapport à une liste requise
  List<String> missingFeatures(List<String> requiredFeatures) =>
      requiredFeatures.where((f) => !scores.containsKey(f)).toList();

  /// Récupère la description (vide si introuvable)
  String descriptionFor(String feature) => roseDescriptions[feature] ?? '';
}
