/*
 * RadarPage
 * -------------
 * This page allows the user to rate their flight skills using a radar chart.
 * - If a radar evaluation already exists for the flight, the page is read-only and shows the chart.
 * - Otherwise, the user can fill sliders for each skill, preview the chart, and save the evaluation.
 * - Intermediate values are saved locally with SharedPreferences for pre-filling.
 * - Final values are saved in the flight repository.
 */
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

  // List of radar features (skills to rate)
  final List<String> features = radarFeatures;
  // Helper to get the short label for a feature
  String _short(String f) => f.split(' - ').first;
  // Stores the current values for each skill
  late final Map<String, double> _values;

  // UI state
  String? _openedFeature;
  bool _showChart = false; // Toggle between form and chart preview
  bool _readOnly = false; // True if radar already exists for this flight
  List<List<double>> _radarData = [];
  final List<int> _ticks = const [5, 10, 15, 20]; // Radar chart ticks

  @override
  void initState() {
    super.initState();
    // Initialize all values to 0 and load flight data
    _values = {for (final f in features) f: 0.0};
    _bootstrap();
  }

  /// Charge le vol : si un radar existe déjà, on passe en lecture seule et on l’affiche.
  Future<void> _bootstrap() async {
    // Loads flight data and determines if the page is read-only or editable.
    if (widget.flightId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing "flightId" parameter (navigation)'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final flight = await _flightRepo.getById(widget.flightId);

    // If flight not found, show error and go back
    if (flight == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flight not found (id=${widget.flightId})')),
      );
      Navigator.pop(context);
      return;
    }

    // If radar already exists, show chart in read-only mode
    if (flight.radar != null) {
      setState(() {
        _readOnly = true;
        _showChart = true;
        _radarData = [flight.radar!.toOrderedList(features)];
      });
      return;
    }

    // Otherwise, try to prefill from local storage
    await _loadSavedValues();

    if (!mounted) return;
  }

  /// Préremplissage local existant (SharedPreferences) — inchangé esthétiquement
  Future<void> _loadSavedValues() async {
    // Loads locally saved values from SharedPreferences for pre-filling the form.
    final prefs = await SharedPreferences.getInstance();
    for (final f in features) {
      final raw = prefs.getString('comp_$f') ?? '';
      final parsed = double.tryParse(raw.replaceAll(',', '.'));
      _values[f] =
          (parsed != null && parsed >= 0 && parsed <= 20) ? parsed : 0.0;
    }
  }

  Future<void> _saveValuesLocally(Map<String, double> values) async {
    // Saves current values locally in SharedPreferences (not final).
    final prefs = await SharedPreferences.getInstance();
    for (final e in values.entries) {
      await prefs.setString('comp_${e.key}', e.value.toString());
    }
  }

  /// Afficher l’aperçu
  void _onSaveAndShow() async {
    // Validates and previews the radar chart (does not save to repository).
    final Map<String, double> values = Map.fromEntries(
      features.map((f) => MapEntry(f, _values[f] ?? 0.0)),
    );

    // Check for invalid values
    final invalids =
        values.entries
            .where((e) => e.value < 0 || e.value > 20)
            .map((e) => e.key)
            .toList();
    if (invalids.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid value (0–20) for: ${invalids.join(', ')}"),
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
    // Finalizes and saves the radar evaluation to the flight repository.
    final invalid = _values.values.any((v) => v < 0 || v > 20);
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All values must be between 0 and 20.")),
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

      // Navigate back to home after saving
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
    // Returns to the form view from the chart preview.
    setState(() => _showChart = false);
  }

  Widget _buildChartView() {
    // Builds the radar chart preview and action buttons.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Preview",
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
            label: const Text("Change values"),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _finalize,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Finalize flight record!"),
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
            label: const Text("Back to home"),
          ),
        ],
      ],
    );
  }

  Widget _buildFormView() {
    // Builds the form for entering radar values.
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final f in features) ...[
            // Each skill slider with label and value
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
                    // Header and value
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
                    // Slider for 0..20
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
            // Show description if this feature is opened
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
          // Button to preview the radar chart
          FilledButton(
            onPressed: _onSaveAndShow,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Show radar chart"),
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
    // Main build method: shows either the form or the radar chart preview
    return AppScaffold(
      title: "Skill Radar",
      showReturnButton: true,
      onReturn: () => Navigator.pushNamed(context, '/postflight_debrief'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _showChart ? _buildChartView() : _buildFormView(),
      ),
    );
  }
}
