import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../controllers/main_tabs_controller.dart';
import '../controllers/templates_controller.dart';
import '../models/template_model.dart';
import '../widgets/gradient_thumbnail.dart';
import 'discover_view.dart';
import 'home_view.dart';
import 'library_view.dart';
import 'profile_view.dart';

/// Bottom navigation: Trends / Discover / Create / Library / Profile.
/// The Create tab opens a template picker that feeds the editor flow.
class MainTabsView extends StatelessWidget {
  const MainTabsView({super.key});

  static const _tabs = [
    BottomNavigationBarItem(
        icon: Icon(Icons.whatshot_outlined),
        activeIcon: Icon(Icons.whatshot),
        label: 'Trends'),
    BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore),
        label: 'Discover'),
    BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'Create'),
    BottomNavigationBarItem(
        icon: Icon(Icons.photo_library_outlined),
        activeIcon: Icon(Icons.photo_library),
        label: 'Library'),
    BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainTabsController());

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.tabIndex.value > 2
                ? controller.tabIndex.value - 1
                : controller.tabIndex.value,
            children: const [
              HomeView(),
              DiscoverView(),
              LibraryView(),
              ProfileView(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            items: _tabs,
            onTap: (i) {
              if (i == 2) {
                _openTemplatePicker(context);
              } else {
                controller.tabIndex.value = i;
              }
            },
          ),
        ));
  }

  void _openTemplatePicker(BuildContext context) {
    final templates = Get.find<TemplatesController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scroll) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pick a template',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: Obx(() => ListView.separated(
                    controller: scroll,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: templates.templates.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final t = templates.templates[i];
                      return _pickerRow(context, t);
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerRow(BuildContext context, TrendTemplate t) {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.toNamed(Routes.editor, arguments: t);
      },
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: GradientThumbnail(
              template: t,
              borderRadius: 14,
              showBadge: false,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${t.category} · ${t.usesLabel} uses',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
