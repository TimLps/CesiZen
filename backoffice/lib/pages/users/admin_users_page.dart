import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/admin_theme.dart';
import '../../models/user.dart';
import '../../providers/admin_providers.dart';
import '../../services/admin_services.dart';
import '../../widgets/admin_widgets.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(_currentPage));

    return Column(
      children: [
        AdminPageHeader(
          title: 'Utilisateurs',
          subtitle: 'Gérer les comptes utilisateurs et administrateurs',
          actions: [
            ElevatedButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouvel utilisateur'),
            ),
          ],
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(adminUsersProvider(_currentPage)),
            ),
            data: (page) => Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 32,
                          horizontalMargin: 24,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nom complet')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Ville')),
                            DataColumn(label: Text('Rôle')),
                            DataColumn(label: Text('État')),
                            DataColumn(label: Text('Inscrit le')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: page.data.map((u) => DataRow(cells: [
                                DataCell(Text('#${u.id}')),
                                DataCell(Text(u.fullName)),
                                DataCell(Text(u.email)),
                                DataCell(Text(u.city ?? '—')),
                                DataCell(_RoleBadge(label: u.role?.label ?? '—',
                                    isAdmin: u.isAdmin)),
                                DataCell(_StateBadge(u: u)),
                                DataCell(Text(u.createdAt != null
                                    ? DateFormat('dd/MM/yyyy').format(u.createdAt!)
                                    : '—')),
                                DataCell(_RowActions(
                                  user: u,
                                  onEdit: () => _openForm(context, user: u),
                                  onDeactivate: () => _deactivate(u),
                                  onDelete: () => _delete(u),
                                )),
                              ])).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pagination
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${page.total} utilisateur(s)',
                          style: const TextStyle(color: AdminColors.textSecondary)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: page.currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text('Page ${page.currentPage} / ${page.lastPage}'),
                          IconButton(
                            onPressed: page.currentPage < page.lastPage
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context, {User? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
    );
    if (result == true) ref.invalidate(adminUsersProvider);
  }

  Future<void> _deactivate(User u) async {
    final confirmed = await _confirm(
      'Désactiver le compte ?',
      'L\'utilisateur ne pourra plus se connecter mais ses données seront conservées.',
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminUserServiceProvider).deactivate(u.id);
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur désactivé')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur'), backgroundColor: AdminColors.error),
        );
      }
    }
  }

  Future<void> _delete(User u) async {
    final confirmed = await _confirm(
      'Supprimer cet utilisateur ?',
      'Cette action est irréversible (soft-delete).',
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(adminUserServiceProvider).delete(u.id);
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur supprimé')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AdminColors.error,
          content: Text('Suppression impossible : $e'),
        ),
      );
    }
  }

  Future<bool?> _confirm(String title, String body) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmer',
                style: TextStyle(color: AdminColors.error)),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final bool isAdmin;
  const _RoleBadge({required this.label, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? AdminColors.primaryDark.withOpacity(0.15)
            : AdminColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? AdminColors.primaryDark : AdminColors.textSecondary,
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final User u;
  const _StateBadge({required this.u});

  @override
  Widget build(BuildContext context) {
    final isActive = u.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AdminColors.success.withOpacity(0.25)
            : AdminColors.error.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        u.state?.label ?? '—',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF2E8B6E) : AdminColors.error,
        ),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;
  const _RowActions({
    required this.user,
    required this.onEdit,
    required this.onDeactivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Modifier')),
        if (user.isActive)
          const PopupMenuItem(value: 'deactivate', child: Text('Désactiver')),
        const PopupMenuItem(value: 'delete',
            child: Text('Supprimer',
                style: TextStyle(color: AdminColors.error))),
      ],
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'deactivate') onDeactivate();
        if (v == 'delete') onDelete();
      },
    );
  }
}

class _UserFormDialog extends ConsumerStatefulWidget {
  final User? user;
  const _UserFormDialog({this.user});

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _cityCtrl;
  int _roleId = 2; // user par défaut
  int _stateId = 1; // active
  bool _isSaving = false;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstNameCtrl = TextEditingController(text: u?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: u?.lastName ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController();
    _cityCtrl = TextEditingController(text: u?.city ?? '');
    if (u?.role != null) _roleId = u!.role!.id;
    if (u?.state != null) _stateId = u!.state!.id;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final svc = ref.read(adminUserServiceProvider);
      final data = <String, dynamic>{
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        'id_role': _roleId,
        'id_user_state': _stateId,
      };
      if (_passwordCtrl.text.isNotEmpty) {
        data['password'] = _passwordCtrl.text;
      }
      if (_isEdit) {
        await svc.update(widget.user!.id, data);
      } else {
        if (_passwordCtrl.text.isEmpty) {
          throw 'Le mot de passe est requis pour la création';
        }
        await svc.create(data);
      }
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Erreur').toString()
          : 'Erreur';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AdminColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_isEdit ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(labelText: 'Prénom *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nom *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _isEdit
                      ? 'Nouveau mot de passe (laisser vide pour conserver)'
                      : 'Mot de passe *',
                ),
                validator: (v) {
                  if (!_isEdit && (v == null || v.isEmpty)) return 'Requis';
                  if (v != null && v.isNotEmpty && v.length < 8) {
                    return '8 caractères minimum';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _roleId,
                      decoration: const InputDecoration(labelText: 'Rôle *'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Administrateur')),
                        DropdownMenuItem(value: 2, child: Text('Utilisateur')),
                      ],
                      onChanged: (v) => setState(() => _roleId = v ?? 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _stateId,
                      decoration: const InputDecoration(labelText: 'État *'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Actif')),
                        DropdownMenuItem(value: 2, child: Text('Inactif')),
                        DropdownMenuItem(value: 3, child: Text('Banni')),
                      ],
                      onChanged: (v) => setState(() => _stateId = v ?? 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isEdit ? 'Enregistrer' : 'Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
