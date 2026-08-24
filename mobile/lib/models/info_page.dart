import 'package:flutter/material.dart';

class InfoPage {
  final int id;
  final String slug;
  final String title;
  final String menuLabel;
  final String content;
  final int? categoryId;
  final int sortOrder;
  final bool isPublished;

  const InfoPage({
    required this.id,
    required this.slug,
    required this.title,
    required this.menuLabel,
    required this.content,
    this.categoryId,
    required this.sortOrder,
    required this.isPublished,
  });

  factory InfoPage.fromJson(Map<String, dynamic> json) => InfoPage(
        id: json['id_info_page'] as int,
        slug: json['slug'] as String,
        title: json['title'] as String,
        menuLabel: json['menu_label'] as String,
        content: json['content'] as String,
        categoryId: json['id_info_page_category'] as int?,
        sortOrder: (json['sort_order'] as int?) ?? 0,
        isPublished: (json['is_published'] as bool?) ?? true,
      );
}

class InfoPageCategory {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? colorHex;
  final int sortOrder;
  final bool isActive;
  final List<InfoPage> pages;

  const InfoPageCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.colorHex,
    required this.sortOrder,
    required this.isActive,
    this.pages = const [],
  });

  Color get color {
    if (colorHex == null || colorHex!.isEmpty) {
      return const Color(0xFFB0E0E6);
    }
    final hex = colorHex!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory InfoPageCategory.fromJson(Map<String, dynamic> json) => InfoPageCategory(
        id: json['id_info_page_category'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        icon: json['icon'] as String?,
        colorHex: json['color_hex'] as String?,
        sortOrder: (json['sort_order'] as int?) ?? 0,
        isActive: (json['is_active'] as bool?) ?? true,
        pages: (json['pages'] as List?)
                ?.map((e) => InfoPage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
