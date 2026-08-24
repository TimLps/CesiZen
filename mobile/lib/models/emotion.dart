import 'package:flutter/material.dart';

class EmotionCategory {
  final int id;
  final String name;
  final String? feelingLabel;
  final String colorHex;
  final String? icon;
  final int sortOrder;
  final bool isActive;
  final List<Emotion> emotions;

  const EmotionCategory({
    required this.id,
    required this.name,
    this.feelingLabel,
    required this.colorHex,
    this.icon,
    required this.sortOrder,
    required this.isActive,
    this.emotions = const [],
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get materialIcon {
    switch (icon) {
      case 'sentiment_very_satisfied':
        return Icons.sentiment_very_satisfied;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      case 'sentiment_dissatisfied':
        return Icons.sentiment_dissatisfied;
      case 'sentiment_very_dissatisfied':
        return Icons.sentiment_very_dissatisfied;
      case 'mood':
        return Icons.mood;
      case 'mood_bad':
        return Icons.mood_bad;
      case 'sick':
        return Icons.sick;
      default:
        return Icons.emoji_emotions_outlined;
    }
  }

  factory EmotionCategory.fromJson(Map<String, dynamic> json) {
    return EmotionCategory(
      id: json['id_emotion_category'] as int,
      name: json['name'] as String,
      feelingLabel: json['feeling_label'] as String?,
      colorHex: json['color_hex'] as String,
      icon: json['icon'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      emotions: (json['emotions'] as List?)
              ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class Emotion {
  final int id;
  final int categoryId;
  final String name;
  final String? feelingLabel;
  final bool isActive;
  final EmotionCategory? category;

  const Emotion({
    required this.id,
    required this.categoryId,
    required this.name,
    this.feelingLabel,
    required this.isActive,
    this.category,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      id: json['id_emotion'] as int,
      categoryId: json['id_emotion_category'] as int,
      name: json['name'] as String,
      feelingLabel: json['feeling_label'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      category: json['category'] != null
          ? EmotionCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}
