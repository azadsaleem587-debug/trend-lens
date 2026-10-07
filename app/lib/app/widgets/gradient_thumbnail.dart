import 'package:flutter/material.dart';
import '../models/template_model.dart';

/// Renders a template's gradient pair as a placeholder thumbnail
/// (no binary assets shipped — gradients stand in for artwork).
class GradientThumbnail extends StatelessWidget {
  final TrendTemplate template;
  final double borderRadius;
  final bool showBadge;
  final bool showPlayIcon;

  const GradientThumbnail({
    super.key,
    required this.template,
    this.borderRadius = 16,
    this.showBadge = true,
    this.showPlayIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [template.startColor, template.endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          if (showPlayIcon)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 40,
              ),
            ),
          if (showBadge && template.isNewDrop)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'NEW DROP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
