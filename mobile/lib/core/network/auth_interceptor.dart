import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

/// Clé utilisée pour la persistance du token dans SharedPreferences
/// (lecture/écriture par le AuthNotifier — l'interceptor lit désormais
/// le token directement depuis le state Riverpod).
const String tokenKey = 'cesizen_auth_token';

/// L'interceptor lit le token depuis le state Riverpod (synchrone) au lieu
/// de SharedPreferences (asynchrone), pour éviter la race condition après
/// login : un délai entre `setString` et `getString` pouvait faire partir
/// la 1ère requête sans Bearer token → HTTP 401.
///
/// On ne déconnecte PAS automatiquement sur 401. C'est trop agressif : une
/// route protégée qui rate (ex : référentiel d'émotions chargé par un visiteur
/// anonyme) faisait alors logout puis redirection vers /login, ou affichait
/// "session expirée" alors que l'utilisateur n'avait jamais été connecté.
/// Les erreurs 401 remontent désormais via Dio et chaque page choisit comment
/// les présenter.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(getToken: () => ref.read(authProvider).token);
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
