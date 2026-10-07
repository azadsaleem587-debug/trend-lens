import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../../theme/app_colors.dart';
import '../controllers/main_tabs_controller.dart';
import '../controllers/templates_controller.dart';
import '../widgets/category_colors.dart';
import '../widgets/category_pill.dart';
import '../widgets/gradient_thumbnail.dart';
import '../widgets/section_header.dart';
import '../widgets/template_card.dart';

/// This Week home: hero carousel, colorful category pills,
/// horizontal template rows and the Fresh Drops grid.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TemplatesController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('This Week'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                Get.find<MainTabsController>().tabIndex.value = 1,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadTemplates,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCarousel(context, controller),
                const SizedBox(height: 20),
                _categoryPills(controller),
                const SizedBox(height: 20),
                ..._templateRows(context, controller),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SectionHeader(
                    title: 'Fresh Drops',
                    onSeeAll: () => controller.selectedCategory.value = 'All',
                  ),
                ),
                _freshDropsGrid(controller),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _heroCarousel(
      BuildContext context, TemplatesController controller) {
    final drops = controller.freshDrops;
    if (drops.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: drops.length,
        itemBuilder: (context, i) {
          final t = drops[i];
          return GestureDetector(
            onTap: () =>
                Get.toNamed(Routes.templateDetail, arguments: t),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GradientThumbnail(
                      template: t,
                      borderRadius: 20,
                      showPlayIcon: false,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'FRESH TREND',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${t.usesLabel} creators already on it',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryPills(TemplatesController controller) {
    return SizedBox(
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
                onTap: () => controller.selectedCategory.value = label,
              ));
        },
      ),
    );
  }

  List<Widget> _templateRows(
      BuildContext context, TemplatesController controller) {
    return TemplatesController.categories
        .where((c) => c != 'All')
        .map((category) {
      final items = controller.templatesFor(category);
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SectionHeader(title: category),
          ),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  TemplateCard(template: items[i]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _freshDropsGrid(TemplatesController controller) {
    final drops = controller.freshDrops;
    if (drops.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No fresh drops yet — check back soon.'),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: drops.length,
      itemBuilder: (context, i) {
        final t = drops[i];
        return GestureDetector(
          onTap: () => Get.toNamed(Routes.templateDetail, arguments: t),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: GradientThumbnail(template: t)),
              const SizedBox(height: 8),
              Text(
                t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${t.usesLabel} uses',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
