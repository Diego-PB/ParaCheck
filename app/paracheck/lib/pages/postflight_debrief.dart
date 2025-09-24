/*
 * This page implements the post-flight debrief form for the user to record flight details and feedback.
 * It loads a list of questions from a local JSON file and presents them as input fields.
 * The user can fill in the answers, validate to save the flight, and see a summary dialog.
 * Data is saved using the SharedPrefsFlightRepository and can be viewed in the flight history.
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:paracheck/models/debrief.dart';
import 'package:paracheck/models/flight.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/utils/parsing_helpers.dart';

import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/input_field.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/design/spacing.dart';

void main() => runApp(const MaterialApp(home: PostFlightDebriefPage()));

class PostFlightDebriefPage extends StatefulWidget {
  const PostFlightDebriefPage({super.key});
  @override
  State<PostFlightDebriefPage> createState() => _PostFlightDebriefPageState();
}

class _PostFlightDebriefPageState extends State<PostFlightDebriefPage> {
  // Path to the JSON file containing post-flight questions
  static const _assetPath = 'assets/postflight_questions.json';

  // Repository for saving and retrieving flights
  final _flightRepo = SharedPrefsFlightRepository();

  // List of questions loaded from the JSON file
  final List<_Q> _questions = [];
  // Controllers for each input field
  final List<TextEditingController> _controllers = [];

  // Loading state for async operations
  bool _loading = true;
  // Error message if loading fails
  String? _error;

  @override
  void initState() {
    super.initState();
    // Load questions and initialize controllers when the page is initialized
    _load();
  }

  Future<void> _load() async {
    // Loads the questions from the local JSON file and initializes controllers
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final list = jsonDecode(raw) as List<dynamic>;
      _questions
        ..clear()
        ..addAll(list.map((e) => _Q.fromJson(e as Map<String, dynamic>)));
      _controllers.clear();
      for (var i = 0; i < _questions.length; i++) {
        // Pre-fill the date field (index 1) with today's date in French format
        if (i == 1) {
          final now = DateTime.now();
          final dateStr =
              "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
          _controllers.add(TextEditingController(text: dateStr));
        } else {
          _controllers.add(TextEditingController());
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = "Erreur de chargement JSON : $e";
        _loading = false;
      });
    }
  }

  Future<void> _valider() async {
    // Validates and saves the debrief form, then shows a summary dialog
    try {
      // Collect flight info from input fields
      final entries = <DebriefEntry>[];
      for (var i = 0; i < _questions.length; i++) {
        final answer = _controllers[i].text.trim();
        if (answer.isNotEmpty) {
          entries.add(DebriefEntry(label: _questions[i].label, value: answer));
        }
      }

      // 0: site, 1: date, 2: duration, 3: altitude
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final site = _controllers[0].text.trim();
      final date = parseDateFr(_controllers[1].text.trim());
      final duration = parseDurationFr(_controllers[2].text.trim());
      final altitude = parseAltitudeMeters(_controllers[3].text.trim());

      final flight = Flight(
        id: id,
        site: site,
        date: date,
        duration: duration,
        altitude: altitude,
        debrief: entries,
      );

      await _flightRepo.add(flight);

      if (!mounted) return;

      // Build a summary buffer for the dialog
      final buffer = StringBuffer();
      for (var i = 0; i < _questions.length; i++) {
        buffer.writeln("• ${_questions[i].label}");
        final txt = _controllers[i].text.trim();
        buffer.writeln(txt.isEmpty ? "—" : txt);
        buffer.writeln();
      }

      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Résumé du débriefing"),
              content: SingleChildScrollView(child: Text(buffer.toString())),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Fermer"),
                ),
              ],
            ),
      );

      if (!mounted) return;
      Navigator.pushNamed(context, '/radar', arguments: {'flightId': id});
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Erreur"),
              content: Text("Erreur de validation : $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Fermer"),
                ),
              ],
            ),
      );
    }
  }

  void _reset() {
    // Clears all input fields in the form
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Main UI for the post-flight debrief form
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return AppScaffold(
      title: "Débrief post-vol",
      showReturnButton: true,
      onReturn: () {
        // Navigate back to the homepage
        Navigator.pushNamed(context, '/homepage');
      },
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Render each question as a title and input field
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionTitle(text: _questions[i].label),
            InputField(
              controller: _controllers[i],
              label:
                  _questions[i].exemple?.isNotEmpty == true
                      ? _questions[i].exemple!
                      : "Réponse",
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.md),

          // Wrap to prevent horizontal overflow of buttons
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              PrimaryButton(
                label: "Valider",
                icon: Icons.check,
                onPressed: _valider,
              ),
              SecondaryButton(label: "Réinitialiser", onPressed: _reset),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Question title that wraps properly across multiple lines.
class _QuestionTitle extends StatelessWidget {
  final String text;
  const _QuestionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }
}

class _Q {
  // Label for the question
  final String label;
  // Example answer (optional)
  final String? exemple;
  const _Q({required this.label, this.exemple});
  factory _Q.fromJson(Map<String, dynamic> m) =>
      _Q(label: m['label'] as String, exemple: m['exemple'] as String?);
}
