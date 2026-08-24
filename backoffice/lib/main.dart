import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/admin_router.dart';
import 'core/theme/admin_theme.dart';

void main() {
  runApp(const ProviderScope(child: CesiZenAdminApp()));
}

class CesiZenAdminApp extends ConsumerWidget {
  const CesiZenAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    return MaterialApp.router(
      title: 'CESIZen Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light(),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),
    );
  }
}
