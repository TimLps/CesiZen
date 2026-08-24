import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/auth_interceptor.dart';
import '../models/admin_models.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../services/admin_services.dart';
import '../services/auth_service.dart';

// ── Auth ─────────────────────────────────────────────────────────────────────

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restoreSession);
    return const AuthState.initial();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    if (token == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    // Injection du token dans le state AVANT /auth/me, pour que l'AuthInterceptor
    // puisse attacher le Bearer (sinon me() partait sans token → 401 → session
    // perdue à chaque ouverture de l'app).
    state = AuthState(token: token, isInitializing: true);

    try {
      final user = await ref.read(authServiceProvider).me();
      state = AuthState(token: token, user: user);
    } catch (_) {
      await prefs.remove(tokenKey);
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    state = AuthState(token: token, user: user);
  }

  Future<void> logout() async {
    // Si on n'a plus de token, inutile d'appeler le serveur.
    final currentToken = state.token;
    if (currentToken == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    // Reset immédiat pour empêcher tout double-tap.
    state = const AuthState.unauthenticated();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);

    try {
      await ref.read(authServiceProvider).logoutWithToken(currentToken);
    } catch (_) {
      // Token déjà invalide côté serveur — on ignore.
    }
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAdminAuthenticated) {
    throw StateError('Session administrateur non initialisée.');
  }
  return ref.read(dashboardServiceProvider).stats();
});

final adminUsersProvider =
    FutureProvider.family<UserPage, int>((ref, page) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAdminAuthenticated) {
    throw StateError('Session administrateur non initialisée.');
  }
  return ref.read(adminUserServiceProvider).list(page: page);
});

final adminInfoPagesProvider = FutureProvider<List<InfoPage>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAdminAuthenticated) {
    throw StateError('Session administrateur non initialisée.');
  }
  return ref.read(adminInfoPageServiceProvider).list();
});

final adminInfoPageCategoriesProvider =
    FutureProvider<List<InfoPageCategory>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAdminAuthenticated) {
    throw StateError('Session administrateur non initialisée.');
  }
  return ref.read(adminInfoPageCategoryServiceProvider).list();
});

final adminEmotionCategoriesProvider =
    FutureProvider<List<EmotionCategory>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAdminAuthenticated) {
    throw StateError('Session administrateur non initialisée.');
  }
  return ref.read(adminEmotionServiceProvider).listCategories();
});
