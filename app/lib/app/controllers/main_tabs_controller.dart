import 'package:get/get.dart';

/// Bottom-tab selection state, shared so Home's search button can
/// jump to the Discover tab.
class MainTabsController extends GetxController {
  final tabIndex = 0.obs;
}
