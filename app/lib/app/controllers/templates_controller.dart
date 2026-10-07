import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import '../models/template_model.dart';
import '../../services/api_service.dart';

/// Loads weekly trend templates from the backend, falling back to the
/// bundled [assets/templates.json] when the server is unreachable.
class TemplatesController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final templates = <TrendTemplate>[].obs;
  final isLoading = true.obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  static const categories = [
    'All',
    'Dance & Sync',
    'Transitions',
    'AI Art Styles',
    'Caption Animations',
  ];

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final list = await _api.fetchTemplates();
      templates.assignAll(list);
    } catch (_) {
      // Backend unreachable — fall back to the bundled sample templates.
      final raw = await rootBundle.loadString('assets/templates.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final list = (data['templates'] as List)
          .map((e) => TrendTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
      templates.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  List<TrendTemplate> get filtered {
    var list = templates.toList();
    if (selectedCategory.value != 'All') {
      list = list.where((t) => t.category == selectedCategory.value).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<TrendTemplate> get freshDrops =>
      templates.where((t) => t.isNewDrop).toList();

  List<TrendTemplate> templatesFor(String category) =>
      templates.where((t) => t.category == category).toList();
}
