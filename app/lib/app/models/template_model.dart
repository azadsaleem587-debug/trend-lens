import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A weekly trend template from the backend or the bundled sample JSON.
class TrendTemplate {
  final String id;
  final String title;
  final String category;
  final int usesCount;
  final bool isNewDrop;
  final String effectType; // filter | caption | aiStyle | transition | beatSync
  final String? aiPrompt;
  final List<String> gradient; // hex pair rendered as a gradient placeholder

  const TrendTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.usesCount,
    this.isNewDrop = false,
    this.effectType = 'filter',
    this.aiPrompt,
    required this.gradient,
  });

  factory TrendTemplate.fromJson(Map<String, dynamic> json) {
    return TrendTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      usesCount: (json['usesCount'] as num).toInt(),
      isNewDrop: json['isNewDrop'] as bool? ?? false,
      effectType: json['effectType'] as String? ?? 'filter',
      aiPrompt: json['aiPrompt'] as String?,
      gradient: (json['gradient'] as List).map((e) => e as String).toList(),
    );
  }

  Color get startColor => hexToColor(gradient[0]);
  Color get endColor =>
      hexToColor(gradient.length > 1 ? gradient[1] : gradient[0]);

  /// Compact "12.4K" style formatting for the uses count.
  String get usesLabel {
    if (usesCount >= 1000000) {
      return '${(usesCount / 1000000).toStringAsFixed(1)}M';
    }
    if (usesCount >= 1000) {
      return '${(usesCount / 1000).toStringAsFixed(1)}K';
    }
    return '$usesCount';
  }
}
