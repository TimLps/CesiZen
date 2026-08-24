import 'emotion.dart';

class JournalEntry {
  final int id;
  final int userId;
  final int emotionId;
  final DateTime date;
  final DateTime? feltAt;
  final String? note;
  final Emotion? emotion;
  final DateTime? createdAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.emotionId,
    required this.date,
    this.feltAt,
    this.note,
    this.emotion,
    this.createdAt,
  });

  /// Timestamp pertinent pour l'UI (priorité au moment ressenti, fallback
  /// sur la date de saisie puis sur la date du journal).
  DateTime get displayMoment => feltAt ?? createdAt ?? date;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id_journal_entry'] as int,
      userId: json['id_user'] as int,
      emotionId: json['id_emotion'] as int,
      date: DateTime.parse(json['entry_date'] as String),
      feltAt: json['felt_at'] != null
          ? DateTime.tryParse(json['felt_at'] as String)
          : null,
      note: json['note'] as String?,
      emotion: json['emotion'] != null
          ? Emotion.fromJson(json['emotion'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class JournalReport {
  final String from;
  final String to;
  final int totalEntries;
  final List<ReportCategoryItem> byCategory;

  const JournalReport({
    required this.from,
    required this.to,
    required this.totalEntries,
    required this.byCategory,
  });

  factory JournalReport.fromJson(Map<String, dynamic> json) {
    return JournalReport(
      from: json['from'] as String,
      to: json['to'] as String,
      totalEntries: (json['total_entries'] as num).toInt(),
      byCategory: (json['by_category'] as List)
          .map((e) => ReportCategoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReportCategoryItem {
  final int categoryId;
  final String name;
  final String? feelingLabel;
  final String colorHex;
  final String? icon;
  final int count;
  final double percentage;

  const ReportCategoryItem({
    required this.categoryId,
    required this.name,
    this.feelingLabel,
    required this.colorHex,
    this.icon,
    required this.count,
    required this.percentage,
  });

  factory ReportCategoryItem.fromJson(Map<String, dynamic> json) {
    return ReportCategoryItem(
      categoryId: json['id_emotion_category'] as int,
      name: json['name'] as String,
      feelingLabel: json['feeling_label'] as String?,
      colorHex: json['color_hex'] as String,
      icon: json['icon'] as String?,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

/// Mini-rapport "X dernières heures" — utilisé sur l'écran d'accueil
/// pour afficher le top 3 catégories.
class WindowReport {
  final int windowHours;
  final int totalEntries;
  final List<ReportCategoryItem> byCategory;

  const WindowReport({
    required this.windowHours,
    required this.totalEntries,
    required this.byCategory,
  });

  factory WindowReport.fromJson(Map<String, dynamic> json) {
    return WindowReport(
      windowHours: (json['window_hours'] as num).toInt(),
      totalEntries: (json['total_entries'] as num).toInt(),
      byCategory: (json['by_category'] as List)
          .map((e) => ReportCategoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
