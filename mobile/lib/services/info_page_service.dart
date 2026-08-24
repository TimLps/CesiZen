import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/info_page.dart';

final infoPageServiceProvider = Provider<InfoPageService>((ref) {
  return InfoPageService(ref.read(dioProvider));
});

class InfoPageService {
  final Dio _dio;
  InfoPageService(this._dio);

  Future<List<InfoPage>> list() async {
    final res = await _dio.get('/info-pages');
    return (res.data as List)
        .map((e) => InfoPage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InfoPage> show(String idOrSlug) async {
    final res = await _dio.get('/info-pages/$idOrSlug');
    return InfoPage.fromJson(res.data as Map<String, dynamic>);
  }

  /// Liste les thèmes avec leurs articles publiés inclus (eager loaded).
  Future<List<InfoPageCategory>> listCategories() async {
    final res = await _dio.get('/info-page-categories');
    return (res.data as List)
        .map((e) => InfoPageCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
