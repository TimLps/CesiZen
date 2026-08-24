import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;
  const AuthResult({required this.token, required this.user});
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResult(
      token: res.data['token'] as String,
      user: User.fromJson(res.data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? city,
    DateTime? birthDate,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (city != null) 'city': city,
      if (birthDate != null)
        'birth_date': birthDate.toIso8601String().split('T').first,
    });
    return AuthResult(
      token: res.data['token'] as String,
      user: User.fromJson(res.data['user'] as Map<String, dynamic>),
    );
  }

  /// Invalide le token côté serveur. Utilisé par AuthNotifier.logout()
  /// — il fournit explicitement le token car au moment de l'appel, le
  /// state Riverpod a déjà été reset à `unauthenticated` pour empêcher
  /// les double-clics, donc l'AuthInterceptor ne le trouverait plus.
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

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? city,
    DateTime? birthDate,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (city != null) data['city'] = city;
    if (birthDate != null) {
      data['birth_date'] = birthDate.toIso8601String().split('T').first;
    }
    final res = await _dio.put('/profile', data: data);
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/profile');
  }

  /// Changement de mot de passe (POST /api/profile/password).
  /// Lève une `DioException` (422) si le mot de passe actuel est incorrect.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/profile/password', data: {
      'current_password'          : currentPassword,
      'new_password'              : newPassword,
      'new_password_confirmation' : newPassword,
    });
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }
}
