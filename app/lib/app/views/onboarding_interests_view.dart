import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes.dart';
import '../widgets/gradient_button.dart';

/// Onboarding step 2: pick content interests to personalize drops.
class OnboardingInterestsView extends StatefulWidget {
  const OnboardingInterestsView({super.key});

  @override
  State<OnboardingInterestsView> createState() =>
      _OnboardingInterestsViewState();
}

class _OnboardingInterestsViewState extends State<OnboardingInterestsView> {
  final _interests = const [
    'Dance & Sync',
    'Transitions',
    'AI Art Styles',
    'Caption Animations',
  ];
  final _selected = <String>{};

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('interests', _selected.toList());
    Get.toNamed(Routes.onboardingAlerts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your interests')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you create?',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick at least one — we will surface matching trends first.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _interests.map((i) {
                  final selected = _selected.contains(i);
                  return ChoiceChip(
                    label: Text(i),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      if (selected) {
                        _selected.remove(i);
                      } else {
                        _selected.add(i);
                      }
                    }),
                  );
                }).toList(),
              ),
              const Spacer(),
              GradientButton(
                label: 'Continue',
                onPressed: _selected.isEmpty ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
