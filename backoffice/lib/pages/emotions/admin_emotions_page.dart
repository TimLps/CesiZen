import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/admin_theme.dart';
import '../../models/admin_models.dart';
import '../../providers/admin_providers.dart';
import '../../services/admin_services.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/cesi_emoji.dart';

class AdminEmotionsPage extends ConsumerWidget {
  const AdminEmotionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminEmotionCategoriesProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Référentiel d\'émotions',
          subtitle:
              '6 catégories de base (niveau 1) et leurs émotions dérivées (niveau 2)',
          actions: [
            ElevatedButton.icon(
              onPressed: () => _openCategoryDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nouvelle catégorie'),
            ),
          ],
        ),
        Expanded(
          child: categoriesAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(adminEmotionCategoriesProvider),
            ),
            data: (categories) {
              if (categories.isEmpty) {
                return const EmptyView(
                  message: 'Aucune catégorie d\'émotion',
                  icon: Icons.emoji_emotions_outlined,
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: categories
                      .map((c) => _CategoryCard(category: c))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openCategoryDialog(BuildContext context, WidgetRef ref,
      {EmotionCategory? category}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CategoryFormDialog(category: category),
    );
    if (result == true) ref.invalidate(adminEmotionCategoriesProvider);
  }
}

class _CategoryCard extends ConsumerWidget {
  final EmotionCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec emoji CESI Zen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.35),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CesiEmoji(
                  emotion: cesiEmotionFromCategoryName(category.name),
                  size: 52,
                  tintColor: category.color,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      if (category.feelingLabel != null && category.feelingLabel!.isNotEmpty)
                        Text(
                          'Vous vous sentez ${category.feelingLabel}',
                          style: const TextStyle(
                              color: AdminColors.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                      Text(category.colorHex,
                          style: const TextStyle(
                              color: AdminColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'monospace')),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer',
                            style: TextStyle(color: AdminColors.error))),
                  ],
                  onSelected: (v) async {
                    if (v == 'edit') {
                      await showDialog<bool>(
                        context: context,
                        builder: (_) => _CategoryFormDialog(category: category),
                      );
                      ref.invalidate(adminEmotionCategoriesProvider);
                    } else if (v == 'delete') {
                      final ok = await _confirmDelete(context);
                      if (ok != true || !context.mounted) return;
                      try {
                        await ref
                            .read(adminEmotionServiceProvider)
                            .deleteCategory(category.id);
                        ref.invalidate(adminEmotionCategoriesProvider);
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
                  },
                ),
              ],
            ),
          ),
          // Émotions niveau 2
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${category.emotions.length} émotion(s)',
                      style: const TextStyle(
                          color: AdminColors.textSecondary, fontSize: 13),
                    ),
                    TextButton.icon(
                      onPressed: () => _addEmotion(context, ref),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (category.emotions.isEmpty)
                  const Text('Aucune émotion dérivée',
                      style: TextStyle(color: AdminColors.textMuted))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: category.emotions
                        .map((e) => _EmotionChip(emotion: e))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la catégorie ?'),
        content: Text(
            'Toutes les émotions de "${category.name}" seront supprimées.'),
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
  }

  Future<void> _addEmotion(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _EmotionFormDialog(categoryId: category.id),
    );
    if (result == true) ref.invalidate(adminEmotionCategoriesProvider);
  }
}

class _EmotionChip extends ConsumerWidget {
  final Emotion emotion;
  const _EmotionChip({required this.emotion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InputChip(
      label: Text(emotion.name),
      backgroundColor: emotion.isActive
          ? AdminColors.background
          : AdminColors.border.withOpacity(0.6),
      labelStyle: TextStyle(
        fontSize: 12,
        color: emotion.isActive
            ? AdminColors.textPrimary
            : AdminColors.textMuted,
      ),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: () async {
        try {
          await ref.read(adminEmotionServiceProvider).deleteEmotion(emotion.id);
          ref.invalidate(adminEmotionCategoriesProvider);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AdminColors.error,
              content: Text('Suppression impossible : $e'),
            ),
          );
        }
      },
    );
  }
}

class _CategoryFormDialog extends ConsumerStatefulWidget {
  final EmotionCategory? category;
  const _CategoryFormDialog({this.category});

  @override
  ConsumerState<_CategoryFormDialog> createState() =>
      _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _feelingCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _iconCtrl;
  late TextEditingController _orderCtrl;
  bool _isSaving = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _feelingCtrl = TextEditingController(text: c?.feelingLabel ?? '');
    _colorCtrl = TextEditingController(text: c?.colorHex ?? '#B0E0E6');
    _iconCtrl = TextEditingController(text: c?.icon ?? '');
    _orderCtrl = TextEditingController(text: (c?.sortOrder ?? 0).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _feelingCtrl.dispose();
    _colorCtrl.dispose();
    _iconCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final svc = ref.read(adminEmotionServiceProvider);
      final data = {
        'name': _nameCtrl.text.trim(),
        'feeling_label':
            _feelingCtrl.text.trim().isEmpty ? null : _feelingCtrl.text.trim(),
        'color_hex': _colorCtrl.text.trim(),
        'icon':
            _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim(),
        'sort_order': int.tryParse(_orderCtrl.text) ?? 0,
        'is_active': true,
      };
      if (_isEdit) {
        await svc.updateCategory(widget.category!.id, data);
      } else {
        await svc.createCategory(data);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.error,
            content: Text(_isEdit
                ? 'Mise à jour impossible : $e'
                : 'Création impossible : $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_isEdit ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feelingCtrl,
                decoration: const InputDecoration(
                  labelText: 'Forme adjectivale',
                  hintText: 'ex : « en colère » → "Vous vous sentez en colère"',
                  helperText: 'Utilisée dans la phrase "Vous vous sentez ..." sur l\'app mobile.',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Couleur HEX *',
                  hintText: '#B0E0E6',
                ),
                validator: (v) {
                  if (v == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(v)) {
                    return 'Format #RRGGBB';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _iconCtrl,
                decoration: const InputDecoration(
                  labelText: 'Icône Material',
                  hintText: 'sentiment_satisfied',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orderCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ordre'),
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
                                strokeWidth: 2),
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

class _EmotionFormDialog extends ConsumerStatefulWidget {
  final int categoryId;
  const _EmotionFormDialog({required this.categoryId});

  @override
  ConsumerState<_EmotionFormDialog> createState() => _EmotionFormDialogState();
}

class _EmotionFormDialogState extends ConsumerState<_EmotionFormDialog> {
  final _nameCtrl = TextEditingController();
  final _feelingCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _feelingCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(adminEmotionServiceProvider).createEmotion({
        'id_emotion_category': widget.categoryId,
        'name': _nameCtrl.text.trim(),
        'feeling_label': _feelingCtrl.text.trim().isEmpty
            ? null
            : _feelingCtrl.text.trim(),
        'is_active': true,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.error,
            content: Text('Création impossible : $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nouvelle émotion',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nom (ex : Hostilité)'),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feelingCtrl,
              decoration: const InputDecoration(
                labelText: 'Forme adjectivale (ex : hostile)',
                helperText: 'Affichée dans "Vous vous sentez ..."',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : const Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
