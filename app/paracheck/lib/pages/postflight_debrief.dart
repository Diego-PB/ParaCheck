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
import 'package:paracheck/services/site_repository.dart';
import 'package:paracheck/utils/parsing_helpers.dart';

import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/input_field.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/design/spacing.dart';

// Standalone entry for local testing of this page.
void main() => runApp(const MaterialApp(home: PostFlightDebriefPage()));

class PostFlightDebriefPage extends StatefulWidget {
  const PostFlightDebriefPage({super.key});
  @override
  State<PostFlightDebriefPage> createState() => _PostFlightDebriefPageState();
}

class _PostFlightDebriefPageState extends State<PostFlightDebriefPage> {
  // JSON asset containing the list of questions to display.
  static const _assetPath = 'assets/postflight_questions.json';

  // Repositories for saving flights and persisting site suggestions.
  final _flightRepo = SharedPrefsFlightRepository();
  final _siteRepo = SharedPrefsSiteRepository();

  // Questions metadata parsed from the JSON.
  final List<_Q> _questions = [];
  // One controller per question input (keeps current text values).
  final List<TextEditingController> _controllers = [];
  // Dedicated controller for the "site" field used by the Autocomplete.
  final TextEditingController _siteController = TextEditingController();
  // Saved site suggestions loaded from SharedPreferences.
  List<String> _siteSuggestions = const [];

  // Page state flags.
  bool _loading = true;
  String? _error;

  // Altitude value controlled by a Slider (in meters).
  double _altitudeMeters = 1000; // default altitude

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Loads the questions from the asset, initializes controllers with defaults,
  // and fetches saved site suggestions.
  Future<void> _load() async {
    try {
      // Load questions
      final raw = await rootBundle.loadString(_assetPath);
      final list = jsonDecode(raw) as List<dynamic>;
      _questions
        ..clear()
        ..addAll(list.map((e) => _Q.fromJson(e as Map<String, dynamic>)));
      _controllers.clear();

      // Initialize one controller per question with sensible defaults
      for (var i = 0; i < _questions.length; i++) {
        if (i == 1) {
          // Question index 1 -> Date (default to today's date)
          final now = DateTime.now();
          final dateStr =
              "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
          _controllers.add(TextEditingController(text: dateStr));
        } else if (i == 2) {
          // Question index 2 -> Duration (default 0h 30m)
          _controllers.add(TextEditingController(text: "0h 30m"));
        } else if (i == 3) {
          // Question index 3 -> Altitude (shown via slider; keep a mirrored text)
          _controllers.add(TextEditingController(text: "1000 m"));
        } else {
          // Generic free text question
          _controllers.add(TextEditingController());
        }
      }

      // Load saved sites for autocomplete suggestions
      _siteSuggestions = await _siteRepo.getAll();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = "Erreur de chargement JSON : $e";
        _loading = false;
      });
    }
  }

  // Date picker for the date question.
  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      locale: const Locale("fr", "FR"),
    );
    if (picked != null) {
      final dateStr =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() => _controllers[index].text = dateStr);
    }
  }

  // Time picker used to build a "Hh Mm" duration string.
  Future<void> _pickDuration(int index) async {
    // Parse current value to pre-fill the picker.
    final parts = _controllers[index].text.split(RegExp(r'[h ]'));
    int hour = 0;
    int minute = 30;
    if (parts.length >= 2) {
      hour = int.tryParse(parts[0]) ?? 0;
      minute = int.tryParse(parts[1]) ?? 30;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      // Force 24h format to match "Hh Mm" display.
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
    );

    if (picked != null) {
      setState(
        () => _controllers[index].text = "${picked.hour}h ${picked.minute}m",
      );
    }
  }

  // Validate and save the debrief:
  // - Aggregate answers
  // - Parse date/duration
  // - Create and persist Flight
  // - Save site to suggestions
  // - Show a human-readable summary
  // - Navigate to the radar page
  Future<void> _valider() async {
    try {
      // Collect all non-empty answers as DebriefEntry
      final entries = <DebriefEntry>[];
      for (var i = 0; i < _questions.length; i++) {
        final answer = _controllers[i].text.trim();
        if (answer.isNotEmpty) {
          entries.add(DebriefEntry(label: _questions[i].label, value: answer));
        }
      }

      // Generate a unique a flight id based on current time.
      final id = DateTime.now().microsecondsSinceEpoch.toString();

      // Prefer the site from the dedicated autocomplete controller, fallback to
      // the first question controller if empty (keeps backward compatibility).
      final site =
          _siteController.text.trim().isNotEmpty
              ? _siteController.text.trim()
              : _controllers[0].text.trim();

      // Parse date and duration from their French string representations.
      final date = parseDateFr(_controllers[1].text.trim());
      final duration = parseDurationFr(_controllers[2].text.trim());
      final altitude = _altitudeMeters;

      // Build Flight model instance.
      final flight = Flight(
        id: id,
        site: site,
        date: date,
        duration: duration,
        altitude: altitude.round(),
        debrief: entries,
      );

      // Persist the new flight.
      await _flightRepo.add(flight);

      // Persist the site for future autocomplete suggestions.
      if (site.isNotEmpty) {
        await _siteRepo.add(site);
        _siteSuggestions = await _siteRepo.getAll();
      }

      if (!mounted) return;

      // Build a textual summary of all answers to show in a dialog.
      final buffer = StringBuffer();
      for (var i = 0; i < _questions.length; i++) {
        buffer.writeln("• ${_questions[i].label}");
        final txt = _controllers[i].text.trim();
        buffer.writeln(txt.isEmpty ? "—" : txt);
        buffer.writeln();
      }

      // Show confirmation/summary dialog.
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

      // Navigate to the radar page showing this specific flight.
      Navigator.pushNamed(context, '/radar', arguments: {'flightId': id});
    } catch (e) {
      if (!mounted) return;
      // Display a basic error dialog if anything fails during validation or saving.
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

  // Reset all fields to their default values.
  void _reset() {
    for (final c in _controllers) {
      c.clear();
    }
    _altitudeMeters = 1000;
    _controllers[2].text = "0h 30m"; // default duration
    _controllers[3].text = "1000 m"; // default altitude
    _siteController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks.
    for (final c in _controllers) {
      c.dispose();
    }
    _siteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading and error states
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));

    // Main content using AppScaffold
    return AppScaffold(
      title: "Débrief post-vol",
      showReturnButton: true,
      onReturn: () => Navigator.pushNamed(context, '/homepage'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Dynamically render each question with a specialized input when applicable.
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionTitle(text: _questions[i].label),

            // Question 0: Site with autocomplete suggestions persisted in SharedPreferences.
            if (i == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Autocomplete<String>(
                    // Filter suggestions by substring, case-insensitive.
                    optionsBuilder: (TextEditingValue tev) {
                      final q = tev.text.trim().toLowerCase();
                      if (q.isEmpty) return _siteSuggestions;
                      return _siteSuggestions.where(
                        (s) => s.toLowerCase().contains(q),
                      );
                    },
                    // When a suggestion is selected, sync both the site controller and
                    // the generic question controller used for summaries.
                    onSelected: (String sel) {
                      _siteController.text = sel;
                      _controllers[0].text = sel;
                    },
                    // Customize the text field used by Autocomplete to keep controllers in sync.
                    fieldViewBuilder: (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      // Initialize with cached value when coming back to the screen.
                      if (_siteController.text.isNotEmpty &&
                          _siteController.text != textEditingController.text) {
                        textEditingController.text = _siteController.text;
                        textEditingController
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: textEditingController.text.length,
                          ),
                        );
                      }
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Site de vol',
                        ),
                        // Keep both controllers aligned as the user types.
                        onChanged: (v) {
                          if (_siteController.text != v) {
                            _siteController.text = v;
                          }
                          if (_controllers.isNotEmpty &&
                              _controllers[0].text != v) {
                            _controllers[0].text = v;
                          }
                        },
                      );
                    },
                  ),
                ],
              )
            // Question 1: Date (read-only input that opens a date picker).
            else if (i == 1)
              GestureDetector(
                onTap: () => _pickDate(i),
                child: AbsorbPointer(
                  child: InputField(
                    controller: _controllers[i],
                    label: "Choisir une date",
                  ),
                ),
              )
            // Question 2: Duration (read-only input that opens a time picker).
            else if (i == 2)
              GestureDetector(
                onTap: () => _pickDuration(i),
                child: AbsorbPointer(
                  child: InputField(
                    controller: _controllers[i],
                    label: "Choisir la durée",
                  ),
                ),
              )
            // Question 3: Altitude (interactive slider with mirrored text value).
            else if (i == 3)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    min: 0,
                    max: 6000,
                    divisions: 120, // 50 m increments
                    label: "${_altitudeMeters.round()} m",
                    value: _altitudeMeters,
                    onChanged: (v) {
                      setState(() {
                        _altitudeMeters = v;
                        _controllers[i].text = "${_altitudeMeters.round()} m";
                      });
                    },
                  ),
                  Text(
                    "Altitude sélectionnée : ${_altitudeMeters.round()} m",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            // Any other question: generic text input (with example as label when provided).
            else
              InputField(
                controller: _controllers[i],
                label:
                    _questions[i].exemple?.isNotEmpty == true
                        ? _questions[i].exemple!
                        : "Réponse",
              ),

            const SizedBox(height: AppSpacing.md),
          ],

          // Action buttons: validate and reset
          const SizedBox(height: AppSpacing.md),
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

// Simple title widget for each question to keep spacing and style consistent.
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

// Question model parsed from the JSON asset (label + optional example).
class _Q {
  final String label;
  final String? exemple;
  const _Q({required this.label, this.exemple});
  factory _Q.fromJson(Map<String, dynamic> m) =>
      _Q(label: m['label'] as String, exemple: m['exemple'] as String?);
}
