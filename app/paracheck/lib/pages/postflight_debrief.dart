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
  static const _assetPath = 'assets/postflight_questions.json';
  final _flightRepo = SharedPrefsFlightRepository();

  final List<_Q> _questions = [];
  final List<TextEditingController> _controllers = [];

  bool _loading = true;
  String? _error;

  double _altitudeMeters = 1000; // altitude par défaut

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final list = jsonDecode(raw) as List<dynamic>;
      _questions
        ..clear()
        ..addAll(list.map((e) => _Q.fromJson(e as Map<String, dynamic>)));
      _controllers.clear();
      for (var i = 0; i < _questions.length; i++) {
        if (i == 1) {
          final now = DateTime.now();
          final dateStr =
              "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
          _controllers.add(TextEditingController(text: dateStr));
        } else if (i == 2) {
          // Durée -> default 0h 30m
          _controllers.add(TextEditingController(text: "0h 30m"));
        } else if (i == 3) {
          // Altitude -> controlled by slider
          _controllers.add(TextEditingController(text: "1000 m"));
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

  Future<void> _pickDuration(int index) async {
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

  Future<void> _valider() async {
    try {
      final entries = <DebriefEntry>[];
      for (var i = 0; i < _questions.length; i++) {
        final answer = _controllers[i].text.trim();
        if (answer.isNotEmpty)
          entries.add(DebriefEntry(label: _questions[i].label, value: answer));
      }

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final site = _controllers[0].text.trim();
      final date = parseDateFr(_controllers[1].text.trim());
      final duration = parseDurationFr(_controllers[2].text.trim());
      final altitude = _altitudeMeters;

      final flight = Flight(
        id: id,
        site: site,
        date: date,
        duration: duration,
        altitude: altitude.round(),
        debrief: entries,
      );

      await _flightRepo.add(flight);

      if (!mounted) return;

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
    for (final c in _controllers) c.clear();
    _altitudeMeters = 1000;
    _controllers[2].text = "0h 30m"; // durée par défaut
    _controllers[3].text = "1000 m"; // altitude par défaut
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));

    return AppScaffold(
      title: "Débrief post-vol",
      showReturnButton: true,
      onReturn: () => Navigator.pushNamed(context, '/homepage'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionTitle(text: _questions[i].label),
            if (i == 1) // Date
              GestureDetector(
                onTap: () => _pickDate(i),
                child: AbsorbPointer(
                  child: InputField(
                    controller: _controllers[i],
                    label: "Choisir une date",
                  ),
                ),
              )
            else if (i == 2) // Durée
              GestureDetector(
                onTap: () => _pickDuration(i),
                child: AbsorbPointer(
                  child: InputField(
                    controller: _controllers[i],
                    label: "Choisir la durée",
                  ),
                ),
              )
            else if (i == 3) // Altitude
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    min: 0,
                    max: 6000,
                    divisions: 120, // incrément de 50 m
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
  final String label;
  final String? exemple;
  const _Q({required this.label, this.exemple});
  factory _Q.fromJson(Map<String, dynamic> m) =>
      _Q(label: m['label'] as String, exemple: m['exemple'] as String?);
}
