import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_interceptor.dart';

/// Sélection automatique de l'URL de base selon la plateforme.
/// - Android émulateur : 10.0.2.2 cible le localhost de l'hôte
/// - iOS / Web / Desktop : localhost direct
const String _baseUrlHost     = 'http://localhost:8001/api';
const String _baseUrlAndroid  = 'http://10.0.2.2:8001/api';

String get baseUrl {
  if (kIsWeb) return _baseUrlHost;
  try {
    if (Platform.isAndroid) return _baseUrlAndroid;
  } catch (_) {}
  return _baseUrlHost;
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(ref.read(authInterceptorProvider));

  if (kDebugMode) {
    // Logs synthétiques : juste la ligne de statut + URL, pas les bodies ni
    // headers (qui inondaient la console et brouillaient le debug).
    dio.interceptors.add(LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }

  return dio;
});
