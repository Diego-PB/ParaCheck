import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

// Page "Rose des compétences" avec sliders 0..20 à la place des champs texte.
class RadarPage extends StatefulWidget {
  const RadarPage({super.key});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  final List<String> features = const [
    "PIL - Piloting",
    "FIS - Flight Incident Situation",
    "ADM - Aerodynamics and Meteorology",
    "KWG - Knowledge and Rules",
    "EQP - Equipment",
    "ENV - Environment and Community",
    "DEC - Decisions",
    "STS - Stress Management",
    "FLM - Flight Management",
    "SAW - Situational Awareness",
    "PHY - Physics and Physiology",
  ];

  // Récupère le diminutif avant " - "
  String _short(String f) {
    final i = f.indexOf(' - ');
    return i > 0 ? f.substring(0, i) : f;
  }

  // Descriptions à afficher quand le champ est sélectionné
  final Map<String, String> descriptions = const {
    "PIL - Piloting":
      "Flight plan. Inflation and ground handling. Use of controls and harness. Appropriate takeoff, approach, and landing techniques.",
    "FIS - Flight Incident Situation":
      "The flight envelope. Pitch and roll limits. Emergency and rescue procedures. Effects of being stunned. Reserve parachute.",
    "ADM - Aerodynamics and Meteorology":
      "Flows, traps. Mastering our element.",
    "KWG - Knowledge and Rules":
      "Flight theory, regulations, recommendations, documentation, certificates, responsibilities, accident history.",
    "EQP - Equipment":
      "Operation and use. Aging, care, packing, inspection. Federal recommendations. Flight manual. Certification.",
    "ENV - Environment and Community":
      "Community connections (information, integration, resilience). Environmental impacts and preservation. In-flight vigilance (collision avoidance).",
    "DEC - Decisions":
      "Decision-making procedures and checklist. Biases. Questioning decisions (Plan B).",
    "STS - Stress Management":
      "Feelings, stress mechanisms. Effects of stress, including shock. Consideration and regulation.",
    "FLM - Flight Management":
      "Flight objectives. Choice of slots. Recurring tasks. Flight monitoring. Threats, errors, countermeasures. Debriefing and self-debriefing.",
    "SAW - Situational Awareness":
      "Flight preparation. Information gathering: analysis, anticipation. Threat identification. Cumulative traps, biases.",
    "PHY - Physics and Physiology":
      "Physical and psychological fitness. Fatigue. Warm-up and concentration. Sun protection, hydration, and nutrition.",
  };

  // On garde les TextEditingControllers si tu veux encore afficher / réutiliser la valeur
  late final Map<String, TextEditingController> _controllers;

  // Valeurs numériques actuelles (0..20)
  late final Map<String, double> _values;

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
    _values = {for (final f in features) f: 0.0};
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
      final raw = prefs.getString('comp_$f') ?? '';
      _controllers[f]!.text = raw;
      final parsed = double.tryParse(raw.replaceAll(',', '.'));
      if (parsed != null && parsed >= 0 && parsed <= 20) {
        _values[f] = parsed;
      } else {
        _values[f] = 0.0;
      }
    }
    setState(() {});
  }

  Future<void> _saveValuesLocally(Map<String, double> values) async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in values.entries) {
      await prefs.setString('comp_${e.key}', e.value.toString());
    }
  }

  void _onSaveAndShow() async {
    // Ici toutes les valeurs sont dans _values et sont déjà numériques 0..20
    final Map<String, double> values = Map.fromEntries(
      features.map((f) => MapEntry(f, _values[f] ?? 0.0)),
    );

    // Vérification simple (optionnelle)
    final invalids = values.entries.where((e) => e.value < 0 || e.value > 20).map((e) => e.key).toList();
    if (invalids.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid value (expected 0 to 20) for: ${invalids.join(', ')}"),
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
          "Appreciation",
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
          label: const Text("Change values"),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () {
            print("Finish flight savings !");
            Navigator.pushNamed(context, '/homepage');
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Finish flight savings !"),
              SizedBox(width: 8),
              Icon(Icons.check),
            ],
          ),
        ),
      ],
    );
  }

  // Vue formulaire (avec descriptions sous le slider sélectionné)
  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final f in features) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _openedFeature = f;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "$f",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _values[f]!.toStringAsFixed(0), // entier
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // Slider
                    Slider(
                      value: _values[f]!,
                      min: 0,
                      max: 20,
                      divisions: 20, // pas entier 0..20
                      label: _values[f]!.toStringAsFixed(0),
                      onChanged: (v) {
                        setState(() {
                          _values[f] = v;
                          // Met à jour aussi le controller texte si tu veux conserver l'ancien storage format
                          _controllers[f]!.text = v.toStringAsFixed(0);
                        });
                      },
                    ),
                  ],
                ),
              ),
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
                Text("Show the skills radar"),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Choose a value between 0 and 20 for each skill.",
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
      title: "Skills Radar",
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/postflight_debrief');
      },
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _showChart ? _buildChartView() : _buildFormView(),
      ),
    );
  }
}
