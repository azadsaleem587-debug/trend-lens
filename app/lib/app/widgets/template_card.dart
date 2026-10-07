import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes.dart';
import '../models/template_model.dart';
import 'gradient_thumbnail.dart';

/// Horizontal-row card for a trend template.
class TemplateCard extends StatelessWidget {
  final TrendTemplate template;
  final double width;

  const TemplateCard({
    super.key,
    required this.template,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.templateDetail, arguments: template),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              height: width * 1.25,
              child: GradientThumbnail(template: template),
            ),
            const SizedBox(height: 8),
            Text(
              template.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '${template.usesLabel} uses',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
