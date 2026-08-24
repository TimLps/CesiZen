import 'package:flutter/material.dart';

// ── Pages d'information ──────────────────────────────────────────────────────

class InfoPage {
  final int id;
  final String slug;
  final String title;
  final String menuLabel;
  final String content;
  final int? categoryId;
  final String? categoryName;
  final int sortOrder;
  final bool isPublished;
  final int? createdBy;
  final int? updatedBy;
  final String? creatorName;
  final String? lastEditorName;

  const InfoPage({
    required this.id,
    required this.slug,
    required this.title,
    required this.menuLabel,
    required this.content,
    this.categoryId,
    this.categoryName,
    required this.sortOrder,
    required this.isPublished,
    this.createdBy,
    this.updatedBy,
    this.creatorName,
    this.lastEditorName,
  });

  factory InfoPage.fromJson(Map<String, dynamic> j) {
    final cat = j['category'];
    return InfoPage(
      id: j['id_info_page'] as int,
      slug: j['slug'] as String,
      title: j['title'] as String,
      menuLabel: j['menu_label'] as String,
      content: j['content'] as String,
      categoryId: j['id_info_page_category'] as int?,
      categoryName: cat is Map<String, dynamic> ? cat['name'] as String? : null,
      sortOrder: (j['sort_order'] as int?) ?? 0,
      isPublished: (j['is_published'] as bool?) ?? false,
      createdBy: j['created_by'] as int?,
      updatedBy: j['updated_by'] as int?,
      creatorName: j['creator_name'] as String?,
      lastEditorName: j['last_editor_name'] as String?,
    );
  }
}

class InfoPageCategory {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? colorHex;
  final int sortOrder;
  final bool isActive;
  final int pagesCount;

  const InfoPageCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.colorHex,
    required this.sortOrder,
    required this.isActive,
    this.pagesCount = 0,
  });

  Color get color {
    if (colorHex == null || colorHex!.isEmpty) {
      return const Color(0xFFB0E0E6);
    }
    final hex = colorHex!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory InfoPageCategory.fromJson(Map<String, dynamic> j) => InfoPageCategory(
        id: j['id_info_page_category'] as int,
        name: j['name'] as String,
        slug: j['slug'] as String,
        icon: j['icon'] as String?,
        colorHex: j['color_hex'] as String?,
        sortOrder: (j['sort_order'] as int?) ?? 0,
        isActive: (j['is_active'] as bool?) ?? true,
        pagesCount: (j['pages_count'] as int?) ?? 0,
      );
}

// ── Émotions ─────────────────────────────────────────────────────────────────

class Emotion {
  final int id;
  final int categoryId;
  final String name;
  final String? feelingLabel;
  final bool isActive;

  const Emotion({
    required this.id,
    required this.categoryId,
    required this.name,
    this.feelingLabel,
    required this.isActive,
  });

  factory Emotion.fromJson(Map<String, dynamic> j) => Emotion(
        id: j['id_emotion'] as int,
        categoryId: j['id_emotion_category'] as int,
        name: j['name'] as String,
        feelingLabel: j['feeling_label'] as String?,
        isActive: (j['is_active'] as bool?) ?? true,
      );
}

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

  factory EmotionCategory.fromJson(Map<String, dynamic> j) => EmotionCategory(
        id: j['id_emotion_category'] as int,
        name: j['name'] as String,
        feelingLabel: j['feeling_label'] as String?,
        colorHex: j['color_hex'] as String,
        icon: j['icon'] as String?,
        sortOrder: (j['sort_order'] as int?) ?? 0,
        isActive: (j['is_active'] as bool?) ?? true,
        emotions: (j['emotions'] as List?)
                ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

// ── Dashboard KPIs ───────────────────────────────────────────────────────────

class TopCategoryItem {
  final String name;
  final String colorHex;
  final int total;

  const TopCategoryItem({
    required this.name,
    required this.colorHex,
    required this.total,
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory TopCategoryItem.fromJson(Map<String, dynamic> j) => TopCategoryItem(
        name: j['name'] as String,
        colorHex: j['color_hex'] as String,
        total: (j['total'] as num).toInt(),
      );
}

class DailyEntryItem {
  final DateTime day;
  final int total;

  const DailyEntryItem({required this.day, required this.total});

  factory DailyEntryItem.fromJson(Map<String, dynamic> j) => DailyEntryItem(
        day: DateTime.parse(j['day'] as String),
        total: (j['total'] as num).toInt(),
      );
}

class DashboardStats {
  final int usersTotal;
  final int usersActive;
  final int usersLast30Days;
  final int usersLast7Days;
  final int infoPagesTotal;
  final int infoPagesPublished;
  final int infoPagesDrafts;
  final int emotionCategoriesCount;
  final int emotionsCount;
  final int journalEntriesTotal;
  final int journalEntriesLast7Days;
  final int journalEntriesLast30Days;
  final List<TopCategoryItem> topCategories;
  final List<DailyEntryItem> daily14d;

  const DashboardStats({
    required this.usersTotal,
    required this.usersActive,
    required this.usersLast30Days,
    required this.usersLast7Days,
    required this.infoPagesTotal,
    required this.infoPagesPublished,
    required this.infoPagesDrafts,
    required this.emotionCategoriesCount,
    required this.emotionsCount,
    required this.journalEntriesTotal,
    required this.journalEntriesLast7Days,
    required this.journalEntriesLast30Days,
    required this.topCategories,
    required this.daily14d,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        usersTotal: j['users']['total'] as int,
        usersActive: j['users']['active'] as int,
        usersLast30Days: j['users']['last_30_days'] as int,
        usersLast7Days: (j['users']['last_7_days'] as int?) ?? 0,
        infoPagesTotal: j['info_pages']['total'] as int,
        infoPagesPublished: j['info_pages']['published'] as int,
        infoPagesDrafts: (j['info_pages']['drafts'] as int?) ?? 0,
        emotionCategoriesCount: j['emotions']['categories'] as int,
        emotionsCount: j['emotions']['emotions'] as int,
        journalEntriesTotal: j['journal']['total_entries'] as int,
        journalEntriesLast7Days: j['journal']['last_7_days'] as int,
        journalEntriesLast30Days: (j['journal']['last_30_days'] as int?) ?? 0,
        topCategories: ((j['journal']['top_categories'] as List?) ?? const [])
            .map((e) => TopCategoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        daily14d: ((j['journal']['daily_14d'] as List?) ?? const [])
            .map((e) => DailyEntryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
