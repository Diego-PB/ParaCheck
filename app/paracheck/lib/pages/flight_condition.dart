import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/design/spacing.dart';
import '../widgets/section_title.dart';
import '../widgets/app_notice.dart';
import '../widgets/primary_button.dart';
import '../design/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlightConditionPage extends StatefulWidget {
  const FlightConditionPage({super.key});

  @override
  State<FlightConditionPage> createState() => _FlightConditionPageState();
}

class _FlightConditionPageState extends State<FlightConditionPage> {
  static const _key = 'flight_condition_level';
  int? selectedLevel;

  final conditions = [
    {'level': 1, 'label': 'Calm Conditions'},
    {'level': 2, 'label': 'Medium and localized turbulence'},
    {'level': 3, 'label': 'Strong and frequent turbulence'},
    {'level': 4, 'label': 'Very strong and constant turbulence'},
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, level);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Flight Conditions',
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/homepage');
      },
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Choose the rating'),
            const SizedBox(height: AppSpacing.md),
            Column(
              children:
                  conditions.map((c) {
                    final level = c['level'] as int;
                    return RadioListTile<int>(
                      title: Text(c['label'] as String),
                      value: level,
                      groupValue: selectedLevel,
                      onChanged: (val) {
                        setState(() => selectedLevel = val);
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (selectedLevel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _buildNotice(selectedLevel!),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'A closure is always a pilot error.',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(
                    label: 'Validate',
                    icon: Icons.check,
                    onPressed:
                        selectedLevel == null
                            ? null
                            : () async {
                              await _saveLevel(selectedLevel!);
                              print('Rating saved: $selectedLevel');
                              Navigator.pushNamed(context, '/personal_weather');
                            },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(int level) {
    switch (level) {
      case 1:
        return const AppNotice(
          kind: NoticeKind.valid,
          title: 'Low vigilance',
          message: 'Conditions are calm.',
        );
      case 2:
      case 3:
        return const AppNotice(
          kind: NoticeKind.warning,
          title: 'Medium to high vigilance',
          message: 'Beware of turbulence, stay vigilant.',
        );
      case 4:
        return const AppNotice(
          kind: NoticeKind.attention,
          title: 'Very high vigilance',
          message: 'Conditions are very turbulent, extreme vigilance required!',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
