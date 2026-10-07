import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/creation_storage.dart';

/// My Creations: grid of locally saved exports with view counts.
class LibraryController extends GetxController {
  final _storage = CreationStorage();

  final files = <File>[].obs;
  final isLoading = true.obs;
  final viewCounts = <String, int>{}.obs;

  static const _viewsKey = 'creation_views';

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    isLoading.value = true;
    try {
      files.assignAll(await _storage.listLocal());
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_viewsKey);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        viewCounts.assignAll(
            map.map((k, v) => MapEntry(k, (v as num).toInt())));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerView(File file) async {
    final key = file.path;
    viewCounts[key] = (viewCounts[key] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewsKey, jsonEncode(viewCounts));
  }

  int totalViews() => viewCounts.values.fold(0, (a, b) => a + b);
}

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Creations')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.files.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.reload,
            child: ListView(
              children: const [
                SizedBox(height: 120),
                Icon(Icons.photo_library_outlined, size: 64),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No creations yet.\nUse a template to make your first one!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.reload,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: controller.files.length,
            itemBuilder: (context, i) {
              final file = controller.files[i];
              final views = controller.viewCounts[file.path] ?? 0;
              return GestureDetector(
                onTap: () {
                  controller.registerView(file);
                  Get.dialog(
                    Dialog(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(file, fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      file.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 14, color: theme.hintColor),
                        const SizedBox(width: 4),
                        Text(
                          '$views views',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
