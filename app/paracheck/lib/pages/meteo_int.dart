import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary.button.dart';
import 'package:paracheck/design/spacing.dart';

class MeteoIntPage extends StatefulWidget {
  const MeteoIntPage({super.key});

  @override
  State<MeteoIntPage> createState() => _MeteoIntPageState();
}

class _MeteoIntPageState extends State<MeteoIntPage> {
  List<dynamic> _questions = [];
  // index question -> valeur choisie (le libellé cliqué)
  final Map<int, String> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final raw = await rootBundle.loadString('assets/questionnaire.json');
    final List<dynamic> data = json.decode(raw);
    setState(() => _questions = data);
  }

  void _selectAnswer(int index, String value) {
    setState(() => _answers[index] = value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Météo intérieure',
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _questions.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, i) {
                // Dernier item : zone d’action (Valider)
                if (i == _questions.length) {
                  final allAnswered = _answers.length == _questions.length;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: PrimaryButton(
                      label: 'Valider',
                      icon: Icons.check,
                      onPressed: allAnswered
                          ? () {
                              // Démo : affiche les réponses
                              final lines = _answers.entries.map((e) {
                                final q = _questions[e.key];
                                return 'Q${e.key + 1} — ${q["question"]}: ${e.value}';
                              }).join('\n');
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Réponses'),
                                  content: Text(lines),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : null, // désactive si incomplet
                    ),
                  );
                }

                final q = _questions[i];
                final selected = _answers[i];

                // Helper pour rendre visuel le choix en restant sur SecondaryButton :
                String labelWithTick(String base) =>
                    selected == base ? '✓ $base' : base;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q['question']?.toString() ?? 'Question',
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        SecondaryButton(
                          label: q["answer_ok"],
                          backgroundColor: Colors.green,
                          onPressed: () => _selectAnswer(i, q["answer_ok"]),
                        ),
                        SecondaryButton(
                          label: q["answer_bof"],
                          backgroundColor: Colors.orange,
                          onPressed: () => _selectAnswer(i, q["answer_bof"]),
                        ),
                        SecondaryButton(
                          label: q["answer_nok"],
                          backgroundColor: Colors.red,
                          onPressed: () => _selectAnswer(i, q["answer_nok"]),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
