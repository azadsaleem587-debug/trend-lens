import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../controllers/templates_controller.dart';
import '../models/template_model.dart';
import '../widgets/category_colors.dart';
import '../widgets/category_pill.dart';
import '../widgets/template_card.dart';

/// Discover: search + category pills + full template grid.
class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TemplatesController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: const InputDecoration(
                hintText: 'Search trends…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: TemplatesController.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final label = TemplatesController.categories[i];
                return Obx(() => CategoryPill(
                      label: label,
                      selected: controller.selectedCategory.value == label,
                      color: categoryColor(label),
                      onTap: () =>
                          controller.selectedCategory.value = label,
                    ));
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final items = controller.filtered;
              if (items.isEmpty) {
                return const Center(
                  child: Text('No trends match your search.'),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) =>
                    _gridCard(context, items[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _gridCard(BuildContext context, TrendTemplate t) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.templateDetail, arguments: t),
      child: TemplateCard(template: t, width: double.infinity),
    );
  }
}
