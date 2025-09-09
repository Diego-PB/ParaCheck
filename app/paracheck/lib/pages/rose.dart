import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RoseApp());
}

class RoseApp extends StatelessWidget {
  const RoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rose des compétences',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          labelStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(),
        ),
      ),
      home: const RosePage(),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44, // un peu plus haut pour bien centrer le texte
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap, // 👈 remonte l’événement de tap
        textAlignVertical: TextAlignVertical.center, // 👈 centre le texte
        inputFormatters: keyboardType == TextInputType.number
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              ]
            : null,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,  // 👈 marge verticale égale = centrage visuel
            horizontal: 12,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}


class RosePage extends StatefulWidget {
  const RosePage({super.key});

  @override
  State<RosePage> createState() => _RosePageState();
}

class _RosePageState extends State<RosePage> {
  // Axes (features)
  final List<String> features = const [
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

  // Descriptions à afficher quand le champ est sélectionné
  final Map<String, String> descriptions = const {
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

  late final Map<String, TextEditingController> _controllers;

  // Champ actuellement en focus (pour afficher la description)
  String? _focusedFeature;

  // État d’affichage (formulaire vs radar)
  bool _showChart = false;

  // Données pour le radar
  List<List<double>> _radarData = [];
  List<int> _ticks = const [4, 8, 12, 16, 20]; // échelle 0–20

  @override
  void initState() {
    super.initState();
    _controllers = {for (final f in features) f: TextEditingController()};
    _loadSavedValues();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    for (final f in features) {
      _controllers[f]!.text = prefs.getString('comp_$f') ?? '';
    }
  }

  Future<void> _saveValuesLocally(Map<String, double> values) async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in values.entries) {
      await prefs.setString('comp_${e.key}', e.value.toString());
    }
  }

  // Parse et valide une note 0..20 (accepte virgule ou point)
  double? _parseToDouble0to20(String raw) {
    if (raw.isEmpty) return null;
    final standardized = raw.replaceAll(',', '.');
    final d = double.tryParse(standardized);
    if (d == null) return null;
    if (d < 0 || d > 20) return null;
    return d;
  }

  void _onSaveAndShow() async {
    // 1) lire + valider
    final Map<String, double> values = {};
    final List<String> invalids = [];

    for (final f in features) {
      final raw = _controllers[f]!.text.trim();
      final parsed = _parseToDouble0to20(raw);
      if (parsed == null) {
        invalids.add(f);
      } else {
        values[f] = parsed;
      }
    }

    if (invalids.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Valeur invalide (attendu 0 à 20) pour : ${invalids.join(', ')}",
          ),
        ),
      );
      return;
    }

    // 2) sauvegarde locale
    await _saveValuesLocally(values);

    // 3) construire data (ordre = features)
    final List<double> dataForUser = features.map((f) => values[f]!).toList();

    // 4) afficher le radar (échelle fixe 0–20)
    setState(() {
      _radarData = [dataForUser];
      _ticks = const [4, 8, 12, 16, 20];
      _showChart = true;
      _focusedFeature = null; // on masque les aides
    });
  }

  void _goBackToForm() {
    setState(() {
      _showChart = false;
    });
  }

  // Vue radar seule
  Widget _buildChartView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Aperçu",
          style: TextStyle(fontSize: 14, color: Colors.black87 , fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1,
          child: RadarChart.light(
            ticks: _ticks,
            features: features,
            data: _radarData,
            reverseAxis: false,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _goBackToForm,
          icon: const Icon(Icons.arrow_back),
          label: const Text("Précédent"),
        ),
      ],
    );
  }

  // Vue formulaire (avec descriptions au focus)
  Widget _buildFormView() {
  return SingleChildScrollView(
    child: Column(
      children: [
        for (final f in features) ...[
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                if (hasFocus) {
                  _focusedFeature = f;           // ouvre celui-ci
                } else if (_focusedFeature == f) {
                  _focusedFeature = null;         // ferme si on quitte
                }
              });
            },
            child: InputField(
              controller: _controllers[f]!,
              label: "$f (0 à 20)",
              keyboardType: TextInputType.number,
              onTap: () {
                setState(() {
                  _focusedFeature = f;            // ouvre immédiatement
                });
              },
            ),
          ),
          if (_focusedFeature == f)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10, left: 6, right: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  descriptions[f] ?? "",
                  style: const TextStyle(
                    fontSize: 14,               // 👈 plus grand
                    color: Colors.black87,      // 👈 plus foncé
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _onSaveAndShow,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Afficher la rose"),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Entrez une note entre 0 et 20 pour chaque compétence.",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rose des compétences")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _showChart ? _buildChartView() : _buildFormView(),
      ),
    );
  }
}
