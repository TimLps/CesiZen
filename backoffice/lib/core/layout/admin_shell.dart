import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admin_providers.dart';
import '../../widgets/cesi_logo.dart';
import '../theme/admin_theme.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _items = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Tableau de bord', path: '/'),
    _NavItem(icon: Icons.people_outline, label: 'Utilisateurs', path: '/users'),
    _NavItem(icon: Icons.article_outlined, label: 'Pages d\'information', path: '/info-pages'),
    _NavItem(icon: Icons.emoji_emotions_outlined, label: 'Référentiel d\'émotions', path: '/emotions'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.path;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ─────────────────────────────────────────────────────
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                right: BorderSide(color: AdminColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo CESI Zen (clin d'œil sans bouche, style officiel)
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: CesiLogo(size: 44, withText: true),
                ),
                const Divider(height: 1),
                // Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      final isActive = item.path == '/'
                          ? loc == '/'
                          : loc.startsWith(item.path);
                      return _SidebarLink(
                        item: item,
                        isActive: isActive,
                        onTap: () => context.go(item.path),
                      );
                    },
                  ),
                ),
                // Footer user
                if (user != null) ...[
                  const Divider(height: 1),
                  InkWell(
                    onTap: () => context.go('/profile'),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AdminColors.primary,
                            radius: 18,
                            child: Text(
                              _initials(user.firstName, user.lastName),
                              style: const TextStyle(
                                color: AdminColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                                const Text(
                                  'Administrateur',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Déconnexion',
                            icon: const Icon(Icons.logout,
                                size: 18, color: AdminColors.textMuted),
                            onPressed: () async {
                              await ref.read(authProvider.notifier).logout();
                              if (context.mounted) context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Contenu principal ──────────────────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }

  String _initials(String f, String l) {
    final fi = f.isNotEmpty ? f[0] : '';
    final li = l.isNotEmpty ? l[0] : '';
    return '$fi$li'.toUpperCase();
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}

class _SidebarLink extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarLink({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? AdminColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isActive
                      ? AdminColors.primaryDark
                      : AdminColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AdminColors.primaryDark
                        : AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
