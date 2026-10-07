import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../../theme/app_colors.dart';
import '../controllers/premium_controller.dart';
import '../controllers/theme_controller.dart';
import '../views/library_view.dart' show LibraryController;
import '../widgets/pro_badge.dart';

/// Profile: avatar, stats row, theme selector (Light/Dark/System),
/// settings list and the Go Pro upsell card.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final premium = Get.find<PremiumController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 12),
            Text(
              'Creator',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Obx(() => Text(
                  premium.isPremium.value ? 'Pro member' : 'Free plan',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                )),
            const SizedBox(height: 16),
            Obx(() {
              final lib = Get.find<LibraryController>();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(theme, '${lib.files.length}', 'Creations'),
                  _stat(theme, '${lib.totalViews()}', 'Views'),
                  _stat(theme, premium.isPremium.value ? '∞' : '0',
                      'Cloud saves'),
                ],
              );
            }),
            const SizedBox(height: 20),
            Obx(() => _themeSelector(context, themeController)),
            const SizedBox(height: 20),
            _settingsTile(theme, Icons.notifications_outlined,
                'Drop alerts', 'Get notified about weekly drops', () {}),
            _settingsTile(theme, Icons.privacy_tip_outlined, 'Privacy',
                'How your data is used', () {}),
            _settingsTile(theme, Icons.info_outline, 'About TrendLens',
                'Version 1.0.0', () {}),
            const SizedBox(height: 20),
            Obx(() => premium.isPremium.value
                ? const SizedBox.shrink()
                : _goProCard(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _stat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style:
              theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _themeSelector(
      BuildContext context, ThemeController controller) {
    final theme = Theme.of(context);
    final modes = {
      ThemeMode.light: 'Light',
      ThemeMode.dark: 'Dark',
      ThemeMode.system: 'System',
    };
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: modes.entries.map((e) {
          final selected = controller.themeMode.value == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setMode(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? theme.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? theme.textTheme.bodyLarge?.color
                          : theme.hintColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _settingsTile(ThemeData theme, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _goProCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.paywall),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProBadge(),
                  SizedBox(height: 10),
                  Text(
                    'Go Pro, post first',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No watermark · cloud backup · 48h early access',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
