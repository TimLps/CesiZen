import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;
  const AuthResult({required this.token, required this.user});
}

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.read(dioProvider)));

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<AuthResult> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResult(
      token: res.data['token'] as String,
      user: User.fromJson(res.data['user'] as Map<String, dynamic>),
    );
  }

  /// Invalide le token côté serveur. Le state Riverpod a déjà été reset à
  /// `unauthenticated` au moment de l'appel — on fournit donc explicitement
  /// le token pour que le serveur puisse révoquer la bonne ligne dans
  /// `personal_access_tokens`.
  Future<void> logoutWithToken(String token) async {
    await _dio.post(
      '/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<User> me() async {
    final res = await _dio.get('/auth/me');
    return User.fromJson(res.data as Map<String, dynamic>);
  }
}
