import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/admin_models.dart';
import '../models/user.dart';

// ── Dashboard ────────────────────────────────────────────────────────────────

final dashboardServiceProvider =
    Provider<DashboardService>((ref) => DashboardService(ref.read(dioProvider)));

class DashboardService {
  final Dio _dio;
  DashboardService(this._dio);

  Future<DashboardStats> stats() async {
    final res = await _dio.get('/admin/dashboard');
    return DashboardStats.fromJson(res.data as Map<String, dynamic>);
  }
}

// ── Users ────────────────────────────────────────────────────────────────────

class UserPage {
  final List<User> data;
  final int currentPage;
  final int lastPage;
  final int total;

  UserPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

final adminUserServiceProvider = Provider<AdminUserService>(
    (ref) => AdminUserService(ref.read(dioProvider)));

class AdminUserService {
  final Dio _dio;
  AdminUserService(this._dio);

  Future<UserPage> list({int page = 1}) async {
    final res =
        await _dio.get('/admin/users', queryParameters: {'page': page});
    final users = (res.data['data'] as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = res.data['meta'] as Map<String, dynamic>;
    return UserPage(
      data: users,
      currentPage: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
    );
  }

  Future<User> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/users', data: data);
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<User> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/users/$id', data: data);
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deactivate(int id) async {
    await _dio.patch('/admin/users/$id/deactivate');
  }

  Future<void> delete(int id) async {
    await _dio.delete('/admin/users/$id');
  }
}

// ── Info pages ───────────────────────────────────────────────────────────────

final adminInfoPageServiceProvider = Provider<AdminInfoPageService>(
    (ref) => AdminInfoPageService(ref.read(dioProvider)));

class AdminInfoPageService {
  final Dio _dio;
  AdminInfoPageService(this._dio);

  Future<List<InfoPage>> list() async {
    final res = await _dio.get('/admin/info-pages');
    return (res.data as List)
        .map((e) => InfoPage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InfoPage> show(int id) async {
    final res = await _dio.get('/admin/info-pages/$id');
    return InfoPage.fromJson(res.data as Map<String, dynamic>);
  }

  Future<InfoPage> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/info-pages', data: data);
    return InfoPage.fromJson(res.data as Map<String, dynamic>);
  }

  Future<InfoPage> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/info-pages/$id', data: data);
    return InfoPage.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/admin/info-pages/$id');
  }
}

final adminInfoPageCategoryServiceProvider =
    Provider<AdminInfoPageCategoryService>(
  (ref) => AdminInfoPageCategoryService(ref.read(dioProvider)),
);

class AdminInfoPageCategoryService {
  final Dio _dio;
  AdminInfoPageCategoryService(this._dio);

  Future<List<InfoPageCategory>> list() async {
    final res = await _dio.get('/admin/info-page-categories');
    return (res.data as List)
        .map((e) => InfoPageCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InfoPageCategory> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/info-page-categories', data: data);
    return InfoPageCategory.fromJson(res.data as Map<String, dynamic>);
  }

  Future<InfoPageCategory> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/info-page-categories/$id', data: data);
    return InfoPageCategory.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/admin/info-page-categories/$id');
  }
}

// ── Émotions ─────────────────────────────────────────────────────────────────

final adminEmotionServiceProvider = Provider<AdminEmotionService>(
    (ref) => AdminEmotionService(ref.read(dioProvider)));

class AdminEmotionService {
  final Dio _dio;
  AdminEmotionService(this._dio);

  Future<List<EmotionCategory>> listCategories() async {
    final res = await _dio.get('/admin/emotion-categories');
    return (res.data as List)
        .map((e) => EmotionCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EmotionCategory> createCategory(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/emotion-categories', data: data);
    return EmotionCategory.fromJson(res.data as Map<String, dynamic>);
  }

  Future<EmotionCategory> updateCategory(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/emotion-categories/$id', data: data);
    return EmotionCategory.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('/admin/emotion-categories/$id');
  }

  Future<Emotion> createEmotion(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/emotions', data: data);
    return Emotion.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Emotion> updateEmotion(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/emotions/$id', data: data);
    return Emotion.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteEmotion(int id) async {
    await _dio.delete('/admin/emotions/$id');
  }
}
