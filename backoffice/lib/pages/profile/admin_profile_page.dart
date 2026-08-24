import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/admin_theme.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/admin_widgets.dart';

class AdminProfilePage extends ConsumerWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const LoadingView();
    }

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Mon profil',
          subtitle: 'Informations du compte administrateur',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carte identité
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [Colors.white, AdminColors.primary],
                                  stops: [0.55, 1.0],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initials(user.firstName, user.lastName),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AdminColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      color: AdminColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AdminColors.primaryDark
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shield_outlined,
                                            size: 14,
                                            color: AdminColors.primaryDark),
                                        SizedBox(width: 6),
                                        Text(
                                          'Administrateur',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AdminColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Informations détaillées
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 20),
                            _ProfileRow(
                              icon: Icons.badge_outlined,
                              label: 'Identifiant',
                              value: '#${user.id}',
                            ),
                            const Divider(height: 28),
                            _ProfileRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email,
                            ),
                            const Divider(height: 28),
                            _ProfileRow(
                              icon: Icons.location_city_outlined,
                              label: 'Ville',
                              value: user.city ?? '—',
                            ),
                            const Divider(height: 28),
                            _ProfileRow(
                              icon: Icons.cake_outlined,
                              label: 'Date de naissance',
                              value: user.birthDate != null
                                  ? DateFormat('dd MMMM yyyy', 'fr_FR')
                                      .format(user.birthDate!)
                                  : '—',
                            ),
                            const Divider(height: 28),
                            _ProfileRow(
                              icon: Icons.event_available_outlined,
                              label: 'Compte créé le',
                              value: user.createdAt != null
                                  ? DateFormat('dd MMMM yyyy', 'fr_FR')
                                      .format(user.createdAt!)
                                  : '—',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.logout,
                                color: AdminColors.error),
                            title: const Text(
                              'Se déconnecter',
                              style: TextStyle(
                                color: AdminColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                                'Mettre fin à votre session administrateur'),
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Se déconnecter ?'),
                                  content: const Text(
                                      'Vous devrez vous reconnecter pour accéder au back-office.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('Se déconnecter'),
                                    ),
                                  ],
                                ),
                              );
                              if (!context.mounted) return;
                              if (confirmed != true) return;
                              await ref.read(authProvider.notifier).logout();
                              if (!context.mounted) return;
                              context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AdminColors.primaryDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              color: AdminColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
