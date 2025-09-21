import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:paracheck/models/radar.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

class RadarPage extends StatefulWidget {
  final String flightId;
  const RadarPage({super.key, required this.flightId});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  final FlightRepository _flightRepo = SharedPrefsFlightRepository();

  // Données du radar
  final List<String> features = radarFeatures;
  String _short(String f) => f.split(' - ').first;
  late final Map<String, double> _values;

  // État UI
  String? _openedFeature;
  bool _showChart = false; // formulaire vs aperçu
  bool _readOnly = false; // si déjà enregistré pour ce vol → lecture seule
  List<List<double>> _radarData = [];
  final List<int> _ticks = const [5, 10, 15, 20]; // 0–20

  @override
  void initState() {
    super.initState();
    _values = {for (final f in features) f: 0.0};
    _bootstrap();
  }

  /// Charge le vol : si un radar existe déjà, on passe en lecture seule et on l’affiche.
  Future<void> _bootstrap() async {
    // Paramètre manquant : on sort proprement
    if (widget.flightId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètre "flightId" manquant (navigation)'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final flight = await _flightRepo.getById(widget.flightId);

    // Vol introuvable
    if (flight == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vol introuvable (id=${widget.flightId})')),
      );
      Navigator.pop(context);
      return;
    }

    // Si un radar est déjà attaché au vol → on passe en lecture seule + aperçu direct
    if (flight.radar != null) {
      setState(() {
        _readOnly = true;
        _showChart = true;
        _radarData = [flight.radar!.toOrderedList(features)];
      });
      return;
    }

    // Aucun radar enregistré → on tente le préremplissage local
    await _loadSavedValues();

    if (!mounted) return;
  }

  /// Préremplissage local existant (SharedPreferences) — inchangé esthétiquement
  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    for (final f in features) {
      final raw = prefs.getString('comp_$f') ?? '';
      final parsed = double.tryParse(raw.replaceAll(',', '.'));
      _values[f] =
          (parsed != null && parsed >= 0 && parsed <= 20) ? parsed : 0.0;
    }
  }

  Future<void> _saveValuesLocally(Map<String, double> values) async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in values.entries) {
      await prefs.setString('comp_${e.key}', e.value.toString());
    }
  }

  /// Afficher l’aperçu
  void _onSaveAndShow() async {
    final Map<String, double> values = Map.fromEntries(
      features.map((f) => MapEntry(f, _values[f] ?? 0.0)),
    );

    final invalids =
        values.entries
            .where((e) => e.value < 0 || e.value > 20)
            .map((e) => e.key)
            .toList();
    if (invalids.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Valeur invalide (0–20) pour : ${invalids.join(', ')}"),
        ),
      );
      return;
    }

    await _saveValuesLocally(values);

    setState(() {
      _radarData = [features.map((f) => values[f]!).toList()];
      _showChart = true;
      _openedFeature = null;
    });
  }

  /// Enregistrement définitif dans le vol
  Future<void> _finalize() async {
    final invalid = _values.values.any((v) => v < 0 || v > 20);
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Toutes les valeurs doivent être entre 0 et 20."),
        ),
      );
      return;
    }

    try {
      await _flightRepo.finalizeRadar(
        widget.flightId,
        Radar(scores: Map<String, double>.from(_values)),
      );

      setState(() {
        _readOnly = true;
        _showChart = true;
        _radarData = [features.map((f) => _values[f] ?? 0.0).toList()];
      });

      // Retour à l’accueil
      if (mounted) {
        Navigator.pushNamed(context, '/homepage');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _goBackToForm() {
    setState(() => _showChart = false);
  }

  Widget _buildChartView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Aperçu",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AspectRatio(
          aspectRatio: 1,
          child: RadarChart.light(
            ticks: _ticks,
            features: features.map(_short).toList(),
            data: _radarData,
          ),
        ),
        if (!_readOnly) ...[
          FilledButton.icon(
            onPressed: _goBackToForm,
            icon: const Icon(Icons.arrow_back),
            label: const Text("Changer les valeurs"),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _finalize, // enregistre définitivement dans le vol
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Terminer l'enregistrement du vol !"),
                SizedBox(width: 8),
                Icon(Icons.check),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/homepage'),
            icon: const Icon(Icons.home),
            label: const Text("Retour à l’accueil"),
          ),
        ],
      ],
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final f in features) ...[
            GestureDetector(
              onTap: () => setState(() => _openedFeature = f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête + valeur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _values[f]!.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Slider 0..20
                    Slider(
                      value: _values[f]!,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: _values[f]!.toStringAsFixed(0),
                      onChanged: (v) {
                        setState(() {
                          _values[f] = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_openedFeature == f)
              Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                  bottom: 10,
                  left: 6,
                  right: 6,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    radarDescriptions[f] ?? "",
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
            onPressed:
                _onSaveAndShow, // aperçu uniquement (pas de persistance dans le vol)
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
            "Choisissez une valeur entre 0 et 20 pour chaque compétence.",
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
      onReturn: () => Navigator.pushNamed(context, '/postflight_debrief'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _showChart ? _buildChartView() : _buildFormView(),
      ),
    );
  }
}
