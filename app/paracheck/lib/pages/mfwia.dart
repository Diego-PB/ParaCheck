import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/widgets/app_notice.dart';
import 'package:paracheck/design/spacing.dart';

class MfwiaPage extends StatefulWidget {
  const MfwiaPage({super.key});

  @override
  State<MfwiaPage> createState() => _MfwiaPageState();
}

class _MfwiaPageState extends State<MfwiaPage> {
  List<dynamic> _questions = [];
  final Map<int, String> _answers = {};
  final Set<int> _locked = {};
  int _visibleCount = 1;
  int? _alertIndex;
  bool _progressBlocked = false;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final raw = await rootBundle.loadString('assets/mfwia_questions.json');
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
    if (_progressBlocked || _locked.contains(index)) return;

    setState(() {
      _answers[index] = value;
      _locked.add(index);

      // Règle: 1 rouge
      final c = _countStates();
      final trigger = c.rouges >= 1;

      if (trigger) {
        _progressBlocked = true;
        _alertIndex ??= index;
      } else {
        _progressBlocked = false;
        _alertIndex = null;

        final isLastVisible = index == _visibleCount - 1;
        if (isLastVisible && _visibleCount < _questions.length) {
          _visibleCount += 1;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Comptage global des états
  ({int rouges}) _countStates() {
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
      _answers.length == _questions.length && _questions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'MFWIA',
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/personal_weather');
      },
      body:
          _questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Questions visibles (chat)
                  for (int i = 0; i < _visibleCount; i++) ...[
                    _QuestionBlock(
                      index: i,
                      question: _questions[i] as Map<String, dynamic>,
                      selected: _answers[i],
                      enabled: !_progressBlocked && !_locked.contains(i),
                      onSelect: (value) => _selectAnswer(i, value),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Alerte inline sous la question déclenchante
                    if (_alertIndex != null && _alertIndex == i) ...[
                      const AppNotice(
                        kind: NoticeKind.attention,
                        title: 'Warning',
                        message: 'Make your preparations again, then recheck your equipment.',
                        compact: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          SecondaryButton(
                            label: 'Restart',
                            onPressed: _resetFlow,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ] else
                      const SizedBox(height: AppSpacing.sm),
                  ],

                  // Succès (toutes les questions répondues, et aucune alerte)
                  if (_allAnswered && !_progressBlocked) ...[
                    const AppNotice(
                      kind: NoticeKind.valid,
                      title: 'Optimal Conditions',
                        message:
                          "Your equipment is checked and ready to use.",
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        SecondaryButton(
                          label: "Validate",
                          onPressed: () {
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
  final int index;
  final Map<String, dynamic> question;
  final String? selected;
  final bool enabled;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Message" de l'app (question)
        Text(
          question['question']?.toString() ?? 'Question',
          style: Theme.of(context).textTheme.titleMedium,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: AppSpacing.md),

        // "Message" de l'utilisateur (choix)
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
