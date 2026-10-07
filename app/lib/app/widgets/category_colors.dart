import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Stable accent color per template category for colorful pills/badges.
Color categoryColor(String category) {
  switch (category) {
    case 'Dance & Sync':
      return AppColors.pink;
    case 'Transitions':
      return AppColors.blue;
    case 'AI Art Styles':
      return AppColors.orange;
    case 'Caption Animations':
      return AppColors.success;
    default:
      return AppColors.primary;
  }
}
