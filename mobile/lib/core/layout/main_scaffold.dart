import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Bottom navigation bar 4 onglets, classique :
///   🏠 Accueil   📰 Infos   📓 Journal   👤 Profil
///
/// Si l'utilisateur n'est pas connecté, les onglets Journal et Profil
/// redirigent vers la page de connexion (gardé par le router).
class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = <_TabItem>[
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
        label: 'Accueil', path: '/'),
    _TabItem(icon: Icons.article_outlined, activeIcon: Icons.article_rounded,
        label: 'Infos', path: '/infos'),
    _TabItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded,
        label: 'Journal', path: '/journal'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded,
        label: 'Profil', path: '/profile'),
  ];

  int _indexFromLocation(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/infos')) return 1;
    if (location.startsWith('/journal')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexFromLocation(location);
    final isAuthed = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          final tab = _tabs[i];
          // Onglets nécessitant l'authentification
          final needsAuth = tab.path == '/journal' || tab.path == '/profile';
          if (needsAuth && !isAuthed) {
            context.push('/login');
            return;
          }
          context.go(tab.path);
        },
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon, color: CesiColors.primaryDark),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
