import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../controllers/premium_controller.dart';
import '../widgets/gradient_button.dart';

/// Paywall: monthly vs yearly toggle, early-access badge, feature checklist.
/// Subscribe currently flips PremiumController.isPremium for demo purposes.
///
/// TODO: Replace with real in-app purchases before release —
/// RevenueCat (recommended for cross-platform) or Google Play Billing / StoreKit.
/// Verify the purchase receipt server-side before calling grantPremium().
class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  bool _yearly = false;

  static const _features = [
    'No watermark on exports',
    'Cloud backup for every creation',
    '48h early access to weekly drops',
    'All AI art styles unlocked',
    'Priority rendering queue',
  ];

  Future<void> _subscribe() async {
    // TODO: real IAP flow here — purchase, verify receipt, then grant.
    await Get.find<PremiumController>().grantPremium();
    if (!mounted) return;
    Get.back();
    Get.snackbar(
      'Welcome to Pro',
      'Premium unlocked (demo mode — wire real IAP before release).',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const price = '\$2.99/mo';
    const yearlyPrice = '\$19.99/yr';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '48H EARLY ACCESS TO WEEKLY DROPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'TrendLens Pro',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Post the trend before it trends.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),
              _billingToggle(theme),
              const SizedBox(height: 24),
              Text(
                _yearly ? yearlyPrice : price,
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                _yearly ? 'billed yearly · save 44%' : 'billed monthly',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),
              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              GradientButton(label: 'Subscribe', onPressed: _subscribe),
              const SizedBox(height: 12),
              Text(
                'Cancel anytime. Demo build — real billing not yet wired.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billingToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _toggleOption('Monthly', !_yearly, () {
            setState(() => _yearly = false);
          }),
          _toggleOption('Yearly', _yearly, () {
            setState(() => _yearly = true);
          }),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.heroGradient : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : theme.hintColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
