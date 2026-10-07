import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../models/template_model.dart';
import '../widgets/category_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_thumbnail.dart';

/// Template detail: preview, trend name, sound, uses count,
/// 3-step guide and a sticky "Use Template" CTA.
class TemplateDetailView extends StatelessWidget {
  const TemplateDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final template = Get.arguments as TrendTemplate;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
                child: GradientThumbnail(
                  template: template,
                  borderRadius: 20,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor(template.category)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          template.category,
                          style: TextStyle(
                            color: categoryColor(template.category),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (template.isNewDrop) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'NEW DROP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    template.title,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.music_note,
                          size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Original sound · ${template.title}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        '${template.usesLabel} creators used this',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How it works',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _step(theme, 1, 'Pick photo',
                      'Choose a photo from your gallery.'),
                  _step(theme, 2, 'Apply',
                      'TrendLens applies the ${template.title} effect.'),
                  _step(theme, 3, 'Post',
                      'Export and share to TikTok, Reels or Shorts.'),
                  const SizedBox(height: 100), // room for sticky CTA
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: GradientButton(
            label: 'Use Template',
            onPressed: () =>
                Get.toNamed(Routes.editor, arguments: template),
          ),
        ),
      ),
    );
  }

  Widget _step(ThemeData theme, int number, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
