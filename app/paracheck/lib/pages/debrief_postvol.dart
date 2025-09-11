import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/input_field.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary.button.dart';
import 'package:paracheck/design/spacing.dart';

void main() => runApp(const MaterialApp(home: DebriefPostVolPage()));

class DebriefPostVolPage extends StatefulWidget {
  const DebriefPostVolPage({super.key});
  @override
  State<DebriefPostVolPage> createState() => _DebriefPostVolPageState();
}

class _DebriefPostVolPageState extends State<DebriefPostVolPage> {
  static const _assetPath = 'assets/questions_postvol.json';

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
        ..clear()
        ..addAll(List.generate(_questions.length, (_) => TextEditingController()));
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = "Erreur chargement JSON: $e";
        _loading = false;
      });
    }
  }

  void _valider() {
    final buffer = StringBuffer();
    for (var i = 0; i < _questions.length; i++) {
      buffer.writeln("• ${_questions[i].label}");
      final txt = _controllers[i].text.trim();
      buffer.writeln(txt.isEmpty ? "—" : txt);
      buffer.writeln();
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Résumé du débrief"),
        content: SingleChildScrollView(child: Text(buffer.toString())),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Fermer")),
        ],
      ),
    );
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
      title: "Débrief d'après vol",
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionTitle(text: _questions[i].label),
            InputField(
              controller: _controllers[i],
              label: _questions[i].exemple?.isNotEmpty == true
                  ? _questions[i].exemple!
                  : "Réponse",
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.md),

          // Wrap pour éviter l’overflow horizontal des boutons
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              PrimaryButton(label: "Valider", icon: Icons.check, onPressed: _valider),
              SecondaryButton(label: "Réinitialiser", onPressed: _reset),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
