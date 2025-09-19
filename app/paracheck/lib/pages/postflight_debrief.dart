import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:paracheck/models/flights.dart';
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
      _controllers
        ..clear();
      for (var i = 0; i < _questions.length; i++) {
        // Préremplir le champ de la date (index 1) avec la date du jour au format français
        if (i == 1) {
          final now = DateTime.now();
          final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
          _controllers.add(TextEditingController(text: dateStr));
        } else {
          _controllers.add(TextEditingController());
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = "Loading JSON error: $e";
        _loading = false;
      });
    }
  }

  Future<void> _valider() async {
    try {
      // 0 : site, 1 : date, 2 : durée, 3 : altitude
      final site = _controllers[0].text.trim();
      final date = parseDateFr(_controllers[1].text.trim());
      final duration = parseDurationFr(_controllers[2].text.trim());
      final altitude = parseAltitudeMeters(_controllers[3].text.trim());

      final flight = Flight(
        site: site,
        date: date,
        duration: duration,
        altitude: altitude,
      );

      await _flightRepo.add(flight);

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
              title: const Text("Debrief Summary"),
              content: SingleChildScrollView(child: Text(buffer.toString())),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            ),
      );

      if (!mounted) return;
      Navigator.pushNamed(context, '/radar');
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: Text("Error validating: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            ),
      );
    }
  }

  void _reset() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return AppScaffold(
      title: "Post-Flight Debrief",
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/homepage');
      },
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionTitle(text: _questions[i].label),
            InputField(
              controller: _controllers[i],
              label:
                  _questions[i].exemple?.isNotEmpty == true
                      ? _questions[i].exemple!
                      : "Answer here",
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.md),

          // Wrap pour éviter l’overflow horizontal des boutons
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              PrimaryButton(
                label: "Validate",
                icon: Icons.check,
                onPressed: _valider,
              ),
              SecondaryButton(label: "Reset", onPressed: _reset),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Titre de question qui **wrappe** proprement sur plusieurs lignes.
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
