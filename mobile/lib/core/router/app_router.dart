import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/auth_state.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/auth/forgot_password_page.dart';
import '../../pages/emotion/quick_emotion_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/info/info_category_page.dart';
import '../../pages/info/info_list_page.dart';
import '../../pages/info/info_detail_page.dart';
import '../../pages/journal/journal_page.dart';
import '../../pages/journal/journal_add_edit_page.dart';
import '../../pages/profile/change_password_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/profile/edit_profile_page.dart';
import '../../providers/auth_provider.dart';
import '../layout/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier._guard,
    routes: [
      // Routes publiques (hors layout)
      GoRoute(path: '/login',           builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register',        builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),

      // Routes sous le scaffold avec bottom nav (4 onglets)
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/',         builder: (_, __) => const HomePage()),
          GoRoute(path: '/quick-emotion', builder: (_, __) => const QuickEmotionPage()),
          GoRoute(path: '/infos',    builder: (_, __) => const InfoListPage()),
          GoRoute(
            path: '/infos/category/:slug',
            builder: (_, state) =>
                InfoCategoryPage(slug: state.pathParameters['slug']!),
          ),
          GoRoute(
            path: '/infos/:slug',
            builder: (_, state) =>
                InfoDetailPage(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/journal',     builder: (_, __) => const JournalPage()),
          GoRoute(path: '/journal/new', builder: (_, __) => const JournalAddEditPage()),
          GoRoute(
            path: '/journal/:id/edit',
            builder: (_, state) => JournalAddEditPage(
                entryId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: '/profile',          builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/profile/edit',     builder: (_, __) => const EditProfilePage()),
          GoRoute(path: '/profile/password', builder: (_, __) => const ChangePasswordPage()),
        ],
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  String? _guard(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authProvider);
    final loc = state.uri.path;

    if (auth.isInitializing) return null;

    final isPublicRoute = loc == '/login' || loc == '/register' ||
        loc == '/forgot-password';

    // Visiteur anonyme : accueil + infos uniquement (saisie émotion locale OK,
    // mais journal et profil = obligation d'être connecté)
    final isVisitorAllowed = loc == '/' ||
        loc.startsWith('/infos') ||
        loc == '/quick-emotion';

    if (!auth.isAuthenticated) {
      if (isPublicRoute || isVisitorAllowed) return null;
      return '/login';
    }

    if (isPublicRoute) return '/';

    return null;
  }
}
