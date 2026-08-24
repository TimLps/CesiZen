import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_providers.dart';

/// Clé utilisée pour la persistance du token dans SharedPreferences
/// (lecture/écriture uniquement par le AuthNotifier — l'interceptor lit
/// désormais le token directement depuis le state Riverpod).
const String tokenKey = 'cesizen_admin_token';

/// L'interceptor reçoit une fonction de lecture du token. Lire depuis le state
/// Riverpod (synchrone) évite la race condition qu'on avait à l'ouverture du
/// dashboard juste après login : sur Flutter Web, `SharedPreferences.setString`
/// peut avoir un léger délai avant que `getString` retourne la nouvelle valeur,
/// si bien que la première requête partait sans Bearer token → HTTP 401.
///
/// On ne déconnecte PAS automatiquement sur 401 : c'est trop agressif. Une
/// seule requête qui rate (ex : le token n'est pas encore propagé après login)
/// faisait alors logout puis redirection vers /login, alors qu'un simple retry
/// aurait fonctionné. Les erreurs 401 remontent désormais via Dio normalement
/// et l'utilisateur voit une `ErrorView` avec un bouton "Réessayer".
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    getToken: () => ref.read(authProvider).token,
  );
});

class AuthInterceptor extends Interceptor {
  final String? Function() getToken;

  AuthInterceptor({required this.getToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
