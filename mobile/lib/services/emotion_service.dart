import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/emotion.dart';
import '../models/journal_entry.dart';

/// Exception levée quand l'API renvoie 429 (cooldown 5 min).
class EmotionCooldownException implements Exception {
  final int retryAfterSeconds;
  final String message;
  EmotionCooldownException({required this.retryAfterSeconds, required this.message});

  @override
  String toString() => message;
}

// ── Émotions (référentiel) ───────────────────────────────────────────────────

final emotionServiceProvider = Provider<EmotionService>((ref) {
  return EmotionService(ref.read(dioProvider));
});

class EmotionService {
  final Dio _dio;
  EmotionService(this._dio);

  Future<List<EmotionCategory>> listCategories() async {
    final res = await _dio.get('/emotion-categories');
    return (res.data as List)
        .map((e) => EmotionCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ── Journal ──────────────────────────────────────────────────────────────────

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(ref.read(dioProvider));
});

class JournalService {
  final Dio _dio;
  JournalService(this._dio);

  Future<List<JournalEntry>> list({String? from, String? to}) async {
    final res = await _dio.get('/journal', queryParameters: {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
    return (res.data as List)
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crée une entrée. Lève [EmotionCooldownException] si l'API renvoie 429.
  ///
  /// - [feltAt] = moment réel ressenti (peut être antérieur à maintenant) ;
  ///   par défaut côté serveur, equals to now.
  /// - [date] = date de l'entrée (jour) ; par défaut côté serveur, dérivée de feltAt.
  Future<JournalEntry> create({
    required int emotionId,
    DateTime? feltAt,
    DateTime? date,
    String? note,
  }) async {
    try {
      final res = await _dio.post('/journal', data: {
        'id_emotion': emotionId,
        if (date != null) 'entry_date': date.toIso8601String().split('T').first,
        if (feltAt != null) 'felt_at': feltAt.toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      });
      return JournalEntry.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        final retryAfterHeader = e.response?.headers.value('retry-after');
        final retryAfter = int.tryParse(retryAfterHeader ?? '') ?? 60;
        final message = (e.response?.data is Map &&
                (e.response?.data as Map)['message'] != null)
            ? (e.response?.data as Map)['message'] as String
            : 'Patientez un instant avant une nouvelle saisie.';
        throw EmotionCooldownException(
          retryAfterSeconds: retryAfter,
          message: message,
        );
      }
      rethrow;
    }
  }

  Future<JournalEntry> update({
    required int entryId,
    int? emotionId,
    DateTime? date,
    DateTime? feltAt,
    String? note,
  }) async {
    final data = <String, dynamic>{};
    if (emotionId != null) data['id_emotion'] = emotionId;
    if (date != null) data['entry_date'] = date.toIso8601String().split('T').first;
    if (feltAt != null) data['felt_at'] = feltAt.toIso8601String();
    if (note != null) data['note'] = note;
    final res = await _dio.put('/journal/$entryId', data: data);
    return JournalEntry.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int entryId) async {
    await _dio.delete('/journal/$entryId');
  }

  Future<JournalReport> getReport({
    String period = 'week',
    String? from,
    String? to,
  }) async {
    final res = await _dio.get('/journal/report', queryParameters: {
      'period': period,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
    return JournalReport.fromJson(res.data as Map<String, dynamic>);
  }

  /// Top N catégories sur les 24 dernières heures.
  Future<WindowReport> top24h({int limit = 3}) async {
    final res = await _dio.get(
      '/journal/top-24h',
      queryParameters: {'limit': limit},
    );
    return WindowReport.fromJson(res.data as Map<String, dynamic>);
  }
}
