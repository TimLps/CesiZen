import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/auth_interceptor.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

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

    // On injecte le token dans le state AVANT d'appeler /auth/me, pour que
    // l'AuthInterceptor puisse l'attacher au header Bearer. Sinon me() partait
    // sans token → 401 → on supprimait le token → session perdue à chaque
    // ouverture de l'app.
    state = AuthState(token: token, isInitializing: true);

    try {
      final user = await ref.read(authServiceProvider).me();
      state = AuthState(token: token, user: user);
    } catch (_) {
      // Token réellement invalide côté serveur → on nettoie
      await prefs.remove(tokenKey);
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    state = AuthState(token: token, user: user);
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout({bool revokeOnServer = true}) async {
    // Si on n'a plus de token, inutile d'appeler le serveur (POST /auth/logout
    // partirait sans Bearer et renverrait 401, ce qui polluait la console et
    // pouvait re-déclencher des effets de bord en cascade).
    final currentToken = state.token;
    if (currentToken == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    // On reset le state IMMÉDIATEMENT pour empêcher tout double-tap qui
    // re-déclencherait POST /auth/logout pendant que la première requête
    // est encore en cours.
    state = const AuthState.unauthenticated();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);

    if (revokeOnServer) {
      try {
        // L'AuthInterceptor lit state.token (= null maintenant). On force donc
        // l'attache du Bearer manuellement pour permettre au serveur de bien
        // invalider le token dans personal_access_tokens.
        await ref.read(authServiceProvider).logoutWithToken(currentToken);
      } catch (_) {
        // Token déjà invalide côté serveur ou problème réseau : on ignore.
      }
    }
  }
}
