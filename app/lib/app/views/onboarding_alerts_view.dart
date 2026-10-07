import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes.dart';
import '../widgets/gradient_button.dart';

/// Onboarding step 3: opt in to weekly drop alerts (notification opt-in).
class OnboardingAlertsView extends StatelessWidget {
  const OnboardingAlertsView({super.key});

  Future<void> _finish(bool allowAlerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('drop_alerts', allowAlerts);
    await prefs.setBool('onboarding_done', true);
    Get.offAllNamed(Routes.main);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.notifications_active_outlined, size: 72),
              const SizedBox(height: 24),
              Text(
                'Never miss a drop',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Get a heads-up when this week\'s trend templates land.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
              const Spacer(),
              GradientButton(
                label: 'Allow Drop Alerts',
                onPressed: () => _finish(true),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _finish(false),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
