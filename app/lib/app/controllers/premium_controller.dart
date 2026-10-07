import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has an active Pro subscription.
///
/// TODO: Replace the manual toggle with real in-app purchases
/// (RevenueCat / Google Play Billing / StoreKit) before release.
/// `grantPremium()` is a placeholder that flips the flag for demos and testing.
class PremiumController extends GetxController {
  static const _key = 'is_premium';

  final isPremium = false.obs;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool(_key) ?? false;
  }

  /// TODO: wire to a verified purchase receipt instead of a local flag.
  Future<void> grantPremium() async {
    isPremium.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  Future<void> revokePremium() async {
    isPremium.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}
