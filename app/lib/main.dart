import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/premium_controller.dart';
import 'app/controllers/templates_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/views/editor_view.dart';
import 'app/views/export_view.dart';
import 'app/views/library_view.dart' show LibraryController;
import 'app/views/main_tabs_view.dart';
import 'app/views/onboarding_alerts_view.dart';
import 'app/views/onboarding_interests_view.dart';
import 'app/views/onboarding_platforms_view.dart';
import 'app/views/paywall_view.dart';
import 'app/views/splash_view.dart';
import 'app/views/template_detail_view.dart';
import 'core/routes.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Long-lived services first — controllers find them via Get.find().
  Get.put(ApiService(), permanent: true);
  // TemplatesController is registered once here (not in views) so
  // Home/Discover/MainTabs never double-register it.
  Get.put(TemplatesController(), permanent: true);
  // LibraryController is registered once here so Library/Profile views
  // can share it via Get.find without double-registration.
  Get.put(LibraryController(), permanent: true);

  final themeController = Get.put(ThemeController(), permanent: true);
  await themeController.load();

  final premiumController = Get.put(PremiumController(), permanent: true);
  await premiumController.load();

  runApp(const TrendLensApp());
}

class TrendLensApp extends StatelessWidget {
  const TrendLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: 'TrendLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialRoute: Routes.splash,
        getPages: [
          GetPage(name: Routes.splash, page: () => const SplashView()),
          GetPage(
              name: Routes.onboardingPlatforms,
              page: () => const OnboardingPlatformsView()),
          GetPage(
              name: Routes.onboardingInterests,
              page: () => const OnboardingInterestsView()),
          GetPage(
              name: Routes.onboardingAlerts,
              page: () => const OnboardingAlertsView()),
          GetPage(name: Routes.main, page: () => const MainTabsView()),
          GetPage(
              name: Routes.templateDetail,
              page: () => const TemplateDetailView()),
          GetPage(name: Routes.editor, page: () => const EditorView()),
          GetPage(name: Routes.export, page: () => const ExportView()),
          GetPage(name: Routes.paywall, page: () => const PaywallView()),
        ],
      ),
    );
  }
}
