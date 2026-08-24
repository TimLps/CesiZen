import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../services/auth_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // En-tête avec avatar
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Colors.white, CesiColors.primary],
                      stops: [0.6, 1.0],
                    ),
                    border: Border.all(
                        color: CesiColors.primary, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      _initials(user.firstName, user.lastName),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: CesiColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.fullName,
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                const SizedBox(height: 4),
                Text(user.email,
                    style: const TextStyle(color: CesiColors.textSecondary)),
                if (user.role != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? CesiColors.primary.withOpacity(0.5)
                            : CesiColors.cardBgSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role!.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Informations
          Card(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.location_city_outlined,
                  label: 'Ville',
                  value: user.city ?? '—',
                ),
                const Divider(height: 1, color: Color(0xFFEAEEF1)),
                _InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Date de naissance',
                  value: user.birthDate != null
                      ? DateFormat('dd MMMM yyyy', 'fr_FR')
                          .format(user.birthDate!)
                      : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined,
                      color: CesiColors.primaryDark),
                  title: const Text('Modifier mon profil'),
                  trailing: const Icon(Icons.chevron_right,
                      color: CesiColors.textMuted),
                  onTap: () => context.push('/profile/edit'),
                ),
                const Divider(height: 1, color: Color(0xFFEAEEF1)),
                ListTile(
                  leading: const Icon(Icons.lock_outline,
                      color: CesiColors.primaryDark),
                  title: const Text('Changer mon mot de passe'),
                  trailing: const Icon(Icons.chevron_right,
                      color: CesiColors.textMuted),
                  onTap: () => context.push('/profile/password'),
                ),
                const Divider(height: 1, color: Color(0xFFEAEEF1)),
                ListTile(
                  leading: const Icon(Icons.logout,
                      color: CesiColors.primaryDark),
                  title: const Text('Se déconnecter'),
                  onTap: () async {
                    // On sort de la route protégée AVANT de passer l'état auth
                    // à unauthenticated. Sinon GoRouter peut démonter /profile
                    // au milieu du flux et laisser une page vide transitoire.
                    context.go('/');
                    await ref.read(authProvider.notifier).logout();
                    invalidateSessionData(ref);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFEAEEF1)),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: CesiColors.error),
                  title: const Text('Supprimer mon compte',
                      style: TextStyle(color: CesiColors.error)),
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'CESIZen v1.0',
              style: TextStyle(color: CesiColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // On utilise le `dialogContext` retourné par le builder pour Navigator.pop,
    // sinon Flutter peut pop deux fois (dialog + page Profile) et lever
    // _debugLocked en cours de finalisation de l'arbre.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer mon compte ?'),
        content: const Text(
            'Cette action est définitive. Toutes vos données (journal d\'émotions, profil) seront supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: CesiColors.error)),
          ),
        ],
      ),
    );

    // Le dialog peut s'être fermé alors que la page n'est plus active.
    if (!context.mounted) return;
    if (confirmed != true) return;

    try {
      await ref.read(authServiceProvider).deleteAccount();
      if (!context.mounted) return;
      context.go('/');
      await ref.read(authProvider.notifier).logout(revokeOnServer: false);
      invalidateSessionData(ref);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression.')),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: CesiColors.primaryDark, size: 22),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(color: CesiColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
