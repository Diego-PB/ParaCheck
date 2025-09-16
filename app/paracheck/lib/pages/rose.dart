import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

// Suppression du main() et du RoseApp, la page sera intégrée via AppScaffold

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
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap, // ouvre la description de ce champ
        textAlignVertical: TextAlignVertical.center, // centre le texte
        inputFormatters: keyboardType == TextInputType.number
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              ]
            : null,
        style: const TextStyle(fontSize: AppSpacing.md),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: AppSpacing.md,
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

  // Récupère le diminutif avant " - "
  String _short(String f) {
    final i = f.indexOf(' - ');
    return i > 0 ? f.substring(0, i) : f;
  }

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

  // Champ "ouvert" (description affichée)
  String? _openedFeature;

  // État d’affichage (formulaire vs rose)
  bool _showChart = false;

  // Données pour le radar
  List<List<double>> _radarData = [];
  List<int> _ticks = const [5, 10, 15, 20]; // échelle 0–20

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

    await _saveValuesLocally(values);
    final List<double> dataForUser = features.map((f) => values[f]!).toList();
    setState(() {
      _radarData = [dataForUser];
      _ticks = const [5, 10, 15, 20];
      _showChart = true;
      _openedFeature = null;
    });
  }

  void _goBackToForm() {
    setState(() {
      _showChart = false;
    });
  }

  Widget _buildChartView() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        "Aperçu",
        style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: AppSpacing.md),
      AspectRatio(
        aspectRatio: 1,
        child: RadarChart.light(
          ticks: _ticks,
          features: features.map(_short).toList(), // n’affiche que "PIL", "SIV", etc.
          data: _radarData,
          reverseAxis: false,
        ),
      ),
      FilledButton.icon(
        onPressed: _goBackToForm,
        icon: const Icon(Icons.arrow_back),
        label: const Text("Changer les valeurs"),
      ),
      const SizedBox(height: AppSpacing.lg),
      FilledButton(
        onPressed: () {
          print("Terminer l'enregistrement du vol !");
          Navigator.pushNamed(context, '/homepage');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("Terminer l'enregistrement du vol !"),
            SizedBox(width: 8),
            Icon(Icons.check),
          ],
        ),
      ),
    ],
  );
}


  // Vue formulaire (avec descriptions sous le champ tapé)
  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final f in features) ...[
            // plus besoin de Focus wrapper : on pilote uniquement à l'onTap
            InputField(
              controller: _controllers[f]!,
              label: "$f (0 à 20)",
              keyboardType: TextInputType.number,
              onTap: () {
                setState(() {
                  _openedFeature = f; // ouvre celui-ci et "ferme" les autres
                });
              },
            ),
            if (_openedFeature == f)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 10, left: 6, right: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    descriptions[f] ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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
            style: TextStyle(fontSize: AppSpacing.md, color: Colors.black54),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Rose des compétences",
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/debrief_postvol');
      },
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _showChart ? _buildChartView() : _buildFormView(),
      ),
    );
  }
}
