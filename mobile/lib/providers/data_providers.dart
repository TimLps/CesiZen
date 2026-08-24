import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/emotion.dart';
import '../models/info_page.dart';
import '../models/journal_entry.dart';
import '../services/emotion_service.dart';
import '../services/info_page_service.dart';

// ── Pages d'information ──────────────────────────────────────────────────────

final infoPagesProvider = FutureProvider<List<InfoPage>>((ref) async {
  return ref.read(infoPageServiceProvider).list();
});

final infoPageProvider =
    FutureProvider.family<InfoPage, String>((ref, idOrSlug) async {
  return ref.read(infoPageServiceProvider).show(idOrSlug);
});

/// Thèmes d'articles publiés (eager-loaded avec les pages).
final infoCategoriesProvider =
    FutureProvider<List<InfoPageCategory>>((ref) async {
  return ref.read(infoPageServiceProvider).listCategories();
});

// ── Catégories d'émotions ────────────────────────────────────────────────────

final emotionCategoriesProvider =
    FutureProvider<List<EmotionCategory>>((ref) async {
  return ref.read(emotionServiceProvider).listCategories();
});

// ── Journal d'émotions ───────────────────────────────────────────────────────

class JournalQuery {
  final String? from;
  final String? to;
  const JournalQuery({this.from, this.to});

  @override
  bool operator ==(Object other) =>
      other is JournalQuery && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

final journalEntriesProvider =
    FutureProvider.family<List<JournalEntry>, JournalQuery>(
  (ref, query) async {
    return ref.read(journalServiceProvider).list(from: query.from, to: query.to);
  },
);

class ReportQuery {
  final String period;
  final String? from;
  final String? to;
  const ReportQuery({this.period = 'week', this.from, this.to});

  @override
  bool operator ==(Object other) =>
      other is ReportQuery &&
      other.period == period &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(period, from, to);
}

final journalReportProvider =
    FutureProvider.family<JournalReport, ReportQuery>((ref, query) async {
  return ref.read(journalServiceProvider).getReport(
        period: query.period,
        from: query.from,
        to: query.to,
      );
});

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Provider qui expose la dernière entrée du journal (la plus récente),
/// utile pour l'écran d'accueil afin de décider quel emoji afficher.
final lastJournalEntryProvider = FutureProvider<JournalEntry?>((ref) async {
  final entries = await ref.read(journalServiceProvider).list();
  if (entries.isEmpty) return null;
  // On préfère trier par felt_at puis created_at (instant précis), sinon entry_date.
  entries.sort((a, b) => b.displayMoment.compareTo(a.displayMoment));
  return entries.first;
});

/// Mini-rapport "top 3 catégories sur les 24 dernières heures",
/// affiché sur l'écran d'accueil.
final top24hProvider = FutureProvider<WindowReport>((ref) async {
  return ref.read(journalServiceProvider).top24h(limit: 3);
});

/// Invalide toutes les données dépendant de la session après login/logout
/// ou après une saisie d'émotion.
void invalidateSessionData(WidgetRef ref) {
  ref.invalidate(infoPagesProvider);
  ref.invalidate(emotionCategoriesProvider);
  ref.invalidate(journalEntriesProvider);
  ref.invalidate(journalReportProvider);
  ref.invalidate(lastJournalEntryProvider);
  ref.invalidate(top24hProvider);
}

/// Invalide uniquement les vues qui dépendent du journal — à appeler
/// après création/édition/suppression d'une entrée.
void invalidateJournalViews(WidgetRef ref) {
  ref.invalidate(journalEntriesProvider);
  ref.invalidate(journalReportProvider);
  ref.invalidate(lastJournalEntryProvider);
  ref.invalidate(top24hProvider);
}
