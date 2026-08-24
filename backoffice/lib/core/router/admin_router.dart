import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/auth_state.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/emotions/admin_emotions_page.dart';
import '../../pages/info_pages/admin_info_pages_page.dart';
import '../../pages/info_pages/admin_info_page_edit.dart';
import '../../pages/profile/admin_profile_page.dart';
import '../../pages/users/admin_users_page.dart';
import '../../providers/admin_providers.dart';
import '../layout/admin_shell.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier._guard,
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/users', builder: (_, __) => const AdminUsersPage()),
          GoRoute(path: '/info-pages',
              builder: (_, __) => const AdminInfoPagesPage()),
          GoRoute(path: '/info-pages/new',
              builder: (_, __) => const AdminInfoPageEdit()),
          GoRoute(
            path: '/info-pages/:id/edit',
            builder: (_, state) =>
                AdminInfoPageEdit(pageId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: '/emotions',
              builder: (_, __) => const AdminEmotionsPage()),
          GoRoute(path: '/profile',
              builder: (_, __) => const AdminProfilePage()),
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

    if (loc == '/login') {
      if (auth.isAdminAuthenticated) return '/';
      return null;
    }

    if (!auth.isAuthenticated) return '/login';
    if (!auth.isAdminAuthenticated) return '/login';

    return null;
  }
}
