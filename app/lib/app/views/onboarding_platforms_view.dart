import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes.dart';
import '../widgets/gradient_button.dart';

/// Onboarding step 1: pick the platforms the creator posts on.
class OnboardingPlatformsView extends StatefulWidget {
  const OnboardingPlatformsView({super.key});

  @override
  State<OnboardingPlatformsView> createState() =>
      _OnboardingPlatformsViewState();
}

class _OnboardingPlatformsViewState extends State<OnboardingPlatformsView> {
  final _platforms = const ['TikTok', 'Reels', 'Shorts'];
  final _selected = <String>{'TikTok'};

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('platforms', _selected.toList());
    Get.toNamed(Routes.onboardingInterests);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to TrendLens')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where do you post?',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'We will tailor weekly drops to your platforms.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _platforms.map((p) {
                  final selected = _selected.contains(p);
                  return ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      if (selected) {
                        _selected.remove(p);
                      } else {
                        _selected.add(p);
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
