/*
 * This page implements the MAVIE equipment checklist and preparation flow.
 * It loads a list of questions from a local JSON file and presents them one by one to the user.
 * The user must answer each question; if a critical ("red") answer is given, an alert is shown and progress is blocked until the flow is restarted.
 * When all questions are answered without alerts, the user can validate and proceed to the next step.
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/widgets/app_notice.dart';
import 'package:paracheck/design/spacing.dart';

class MaviePage extends StatefulWidget {
  const MaviePage({super.key});

  @override
  State<MaviePage> createState() => _MaviePageState();
}

class _MaviePageState extends State<MaviePage> {
  // List of questions loaded from the JSON file
  List<dynamic> _questions = [];
  // Stores the user's answers (question index -> answer string)
  final Map<int, String> _answers = {};
  // Tracks which questions are locked (already answered)
  final Set<int> _locked = {};
  // Number of questions currently visible in the flow
  int _visibleCount = 1;
  // Index of the question that triggered an alert, if any
  int? _alertIndex;
  // Whether progress is blocked due to a critical answer
  bool _progressBlocked = false;

  // Controller for scrolling the ListView
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load questions from the local JSON file when the page is initialized
    _loadQuestions();
  }

  @override
  void dispose() {
    // Dispose the scroll controller when the widget is removed
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    // Loads the questions from the local JSON file and resets the flow state
    final raw = await rootBundle.loadString('assets/mavie_questions.json');
    final List<dynamic> data = json.decode(raw);
    setState(() {
      _questions = data;
      _answers.clear();
      _locked.clear();
      _visibleCount = data.isEmpty ? 0 : 1;
      _alertIndex = null;
      _progressBlocked = false;
    });
  }

  void _resetFlow() {
    // Resets the flow to the initial state and scrolls to the top
    setState(() {
      _answers.clear();
      _locked.clear();
      _visibleCount = _questions.isEmpty ? 0 : 1;
      _alertIndex = null;
      _progressBlocked = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    });
  }

  void _selectAnswer(int index, String value) {
    // Handles user answer selection for a question
    // If progress is blocked or question is locked, do nothing
    if (_progressBlocked || _locked.contains(index)) return;

    setState(() {
      _answers[index] = value;
      _locked.add(index);

      // Rule: If at least one "red" answer, block progress and show alert
      final c = _countStates();
      final trigger = c.rouges >= 1;

      if (trigger) {
        _progressBlocked = true;
        _alertIndex ??= index;
      } else {
        _progressBlocked = false;
        _alertIndex = null;

        // Reveal next question if current is last visible
        final isLastVisible = index == _visibleCount - 1;
        if (isLastVisible && _visibleCount < _questions.length) {
          _visibleCount += 1;
        }
      }
    });

    // Scroll to bottom after answering
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    // Animates the ListView to the bottom
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Comptage global des états
  ({int rouges}) _countStates() {
    // Counts the number of "red" (critical) answers
    int rouges = 0;
    for (final entry in _answers.entries) {
      final i = entry.key;
      if (i < 0 || i >= _questions.length) continue;
      final q = _questions[i] as Map<String, dynamic>;
      final v = entry.value;
      if (v == q['answer_nok']) rouges++;
    }
    return (rouges: rouges);
  }

  bool get _allAnswered =>
      // Returns true if all questions have been answered
      _answers.length == _questions.length && _questions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Main UI for the MAVIE checklist page
    return AppScaffold(
      title: 'MAVIE',
      showReturnButton: true,
      onReturn: () {
        // Navigate back to the previous page
        Navigator.pushNamed(context, '/personal_weather');
      },
      body:
          _questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Display each visible question block
                  for (int i = 0; i < _visibleCount; i++) ...[
                    _QuestionBlock(
                      index: i,
                      question: _questions[i] as Map<String, dynamic>,
                      selected: _answers[i],
                      enabled: !_progressBlocked && !_locked.contains(i),
                      onSelect: (value) => _selectAnswer(i, value),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Inline alert shown below the triggering question
                    if (_alertIndex != null && _alertIndex == i) ...[
                      const AppNotice(
                        kind: NoticeKind.attention,
                        title: 'Alerte',
                        message:
                            'Refaites vos préparatifs, puis vérifiez à nouveau votre équipement.',
                        compact: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          SecondaryButton(
                            label: 'Redémarrer',
                            onPressed: _resetFlow,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ] else
                      const SizedBox(height: AppSpacing.sm),
                  ],

                  // Success message and validation button if all questions answered and no alert
                  if (_allAnswered && !_progressBlocked) ...[
                    const AppNotice(
                      kind: NoticeKind.valid,
                      title: 'Conditions optimales',
                      message:
                          "Votre équipement est vérifié et prêt à l'emploi.",
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        SecondaryButton(
                          label: "Valider",
                          onPressed: () {
                            // Proceed to the next step
                            Navigator.pushNamed(context, '/breathing');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  // Index of the question in the list
  final int index;
  // Question data (text and answers)
  final Map<String, dynamic> question;
  // Currently selected answer for this question
  final String? selected;
  // Whether the answer buttons are enabled
  final bool enabled;
  // Callback when an answer is selected
  final ValueChanged<String> onSelect;

  const _QuestionBlock({
    required this.index,
    required this.question,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Renders a single question block with answer buttons
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Text(
          question['question']?.toString() ?? 'Question',
          style: Theme.of(context).textTheme.titleMedium,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: AppSpacing.md),

        // Answer buttons (OK/Not OK)
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SecondaryButton(
              label: question["answer_ok"],
              backgroundColor: Colors.green,
              selected: selected == question["answer_ok"],
              onPressed: enabled ? () => onSelect(question["answer_ok"]) : null,
            ),
            SecondaryButton(
              label: question["answer_nok"],
              backgroundColor: Colors.red,
              selected: selected == question["answer_nok"],
              onPressed:
                  enabled ? () => onSelect(question["answer_nok"]) : null,
            ),
          ],
        ),
      ],
    );
  }
}
