import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/admin_theme.dart';
import '../../models/admin_models.dart';
import '../../providers/admin_providers.dart';
import '../../services/admin_services.dart';
import '../../widgets/admin_widgets.dart';

class AdminInfoPagesPage extends ConsumerWidget {
  const AdminInfoPagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(adminInfoPagesProvider);
    return Column(
      children: [
        AdminPageHeader(
          title: 'Pages d\'information',
          subtitle: 'Gérer les contenus éditoriaux du Front-Office',
          actions: [
            OutlinedButton.icon(
              onPressed: () => _openCategoryManager(context, ref),
              icon: const Icon(Icons.folder_outlined, size: 18),
              label: const Text('Thèmes'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => context.push('/info-pages/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouvelle page'),
            ),
          ],
        ),
        Expanded(
          child: pagesAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(adminInfoPagesProvider),
            ),
            data: (pages) {
              if (pages.isEmpty) {
                return const EmptyView(
                  message: 'Aucune page créée pour le moment',
                  icon: Icons.article_outlined,
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Card(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AdminColors.border)),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                                width: 60,
                                child: Text('Ordre',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textSecondary,
                                        fontSize: 13))),
                            Expanded(
                                flex: 3,
                                child: Text('Titre',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textSecondary,
                                        fontSize: 13))),
                            Expanded(
                                flex: 2,
                                child: Text('Thème',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textSecondary,
                                        fontSize: 13))),
                            Expanded(
                                flex: 2,
                                child: Text('Créé par',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textSecondary,
                                        fontSize: 13))),
                            SizedBox(
                                width: 100,
                                child: Text('Statut',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textSecondary,
                                        fontSize: 13))),
                            SizedBox(
                                width: 80,
                                child: Text('Actions',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textSecondary,
                                        fontSize: 13))),
                          ],
                        ),
                      ),
                      // Rows
                      ...pages.map((page) => _PageRow(page: page)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openCategoryManager(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const _InfoCategoryManagerDialog(),
    );
    if (result == true) {
      ref.invalidate(adminInfoPageCategoriesProvider);
      ref.invalidate(adminInfoPagesProvider);
    }
  }
}

class _PageRow extends ConsumerWidget {
  final InfoPage page;
  const _PageRow({required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.push('/info-pages/${page.id}/edit'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AdminColors.border)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text('#${page.sortOrder}',
                  style: const TextStyle(color: AdminColors.textSecondary)),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(page.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(page.menuLabel,
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textMuted)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(page.categoryName ?? 'Sans thème',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AdminColors.textSecondary)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                page.lastEditorName ?? page.creatorName ?? 'Non renseigné',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: page.isPublished
                      ? AdminColors.success.withOpacity(0.25)
                      : AdminColors.warning.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    page.isPublished ? 'Publié' : 'Brouillon',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: page.isPublished
                          ? const Color(0xFF2E8B6E)
                          : const Color(0xFFB8741F),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () =>
                        context.push('/info-pages/${page.id}/edit'),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AdminColors.error),
                    onPressed: () => _confirmDelete(context, ref),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette page ?'),
        content: Text('"${page.title}" sera définitivement supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: AdminColors.error)),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed != true) return;
    try {
      await ref.read(adminInfoPageServiceProvider).delete(page.id);
      ref.invalidate(adminInfoPagesProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AdminColors.error,
          content: Text('Suppression impossible : $e'),
        ),
      );
    }
  }
}

class _InfoCategoryManagerDialog extends ConsumerStatefulWidget {
  const _InfoCategoryManagerDialog();

  @override
  ConsumerState<_InfoCategoryManagerDialog> createState() =>
      _InfoCategoryManagerDialogState();
}

class _InfoCategoryManagerDialogState
    extends ConsumerState<_InfoCategoryManagerDialog> {
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _colorCtrl = TextEditingController(text: '#B0E0E6');
  final _orderCtrl = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _colorCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  String _slugify(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r"[àáâãäå]"), 'a')
      .replaceAll(RegExp(r"[èéêë]"), 'e')
      .replaceAll(RegExp(r"[ìíîï]"), 'i')
      .replaceAll(RegExp(r"[òóôõö]"), 'o')
      .replaceAll(RegExp(r"[ùúûü]"), 'u')
      .replaceAll(RegExp(r"[ç]"), 'c')
      .replaceAll(RegExp(r"[^a-z0-9]+"), '-')
      .replaceAll(RegExp(r"^-+|-+$"), '');

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminInfoPageCategoryServiceProvider).create({
        'name': name,
        'slug': _slugCtrl.text.trim().isEmpty
            ? _slugify(name)
            : _slugCtrl.text.trim(),
        'color_hex': _colorCtrl.text.trim(),
        'sort_order': int.tryParse(_orderCtrl.text) ?? 0,
        'is_active': true,
      });
      _nameCtrl.clear();
      _slugCtrl.clear();
      _orderCtrl.text = '0';
      ref.invalidate(adminInfoPageCategoriesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AdminColors.error,
          content: Text('Création impossible : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(InfoPageCategory category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce thème ?'),
        content: Text(
          '"${category.name}" sera détaché des pages associées, mais les pages seront conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: AdminColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminInfoPageCategoryServiceProvider).delete(category.id);
      ref.invalidate(adminInfoPageCategoriesProvider);
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminInfoPageCategoriesProvider);

    return Dialog(
      child: SizedBox(
        width: 720,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Thèmes des pages d\'information',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              categoriesAsync.when(
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(adminInfoPageCategoriesProvider),
                ),
                data: (categories) => ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final category = categories[i];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: category.color),
                        title: Text(category.name),
                        subtitle: Text(
                          '${category.slug} · ${category.pagesCount} page(s)',
                        ),
                        trailing: IconButton(
                          tooltip: 'Supprimer',
                          icon: const Icon(Icons.delete_outline,
                              color: AdminColors.error),
                          onPressed: () => _delete(category),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ajouter un thème',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _slugCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Slug (optionnel)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _colorCtrl,
                      decoration: const InputDecoration(labelText: 'Couleur'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _orderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ordre'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Fermer'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _create,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter'),
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
