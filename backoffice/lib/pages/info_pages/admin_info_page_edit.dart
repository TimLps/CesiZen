import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/admin_theme.dart';
import '../../providers/admin_providers.dart';
import '../../services/admin_services.dart';
import '../../widgets/admin_widgets.dart';

class AdminInfoPageEdit extends ConsumerStatefulWidget {
  final int? pageId;
  const AdminInfoPageEdit({super.key, this.pageId});

  @override
  ConsumerState<AdminInfoPageEdit> createState() => _AdminInfoPageEditState();
}

class _AdminInfoPageEditState extends ConsumerState<AdminInfoPageEdit> {
  final _formKey = GlobalKey<FormState>();
  final _slugCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _menuLabelCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _sortOrderCtrl = TextEditingController(text: '0');
  int? _categoryId;
  bool _isPublished = true;
  bool _isLoading = false;
  bool _initialFetched = false;

  bool get _isEdit => widget.pageId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage());
    }
  }

  Future<void> _loadPage() async {
    setState(() => _isLoading = true);
    try {
      final page =
          await ref.read(adminInfoPageServiceProvider).show(widget.pageId!);
      if (!mounted) return;
      _slugCtrl.text = page.slug;
      _titleCtrl.text = page.title;
      _menuLabelCtrl.text = page.menuLabel;
      _contentCtrl.text = page.content;
      _sortOrderCtrl.text = page.sortOrder.toString();
      setState(() {
        _categoryId = page.categoryId;
        _isPublished = page.isPublished;
        _initialFetched = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AdminColors.error,
          content: Text('Chargement impossible : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _titleCtrl.dispose();
    _menuLabelCtrl.dispose();
    _contentCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final svc = ref.read(adminInfoPageServiceProvider);
      final data = {
        'slug': _slugCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'menu_label': _menuLabelCtrl.text.trim(),
        'content': _contentCtrl.text,
        'id_info_page_category': _categoryId,
        'sort_order': int.tryParse(_sortOrderCtrl.text) ?? 0,
        'is_published': _isPublished,
      };
      if (_isEdit) {
        await svc.update(widget.pageId!, data);
      } else {
        await svc.create(data);
      }
      ref.invalidate(adminInfoPagesProvider);
      if (mounted) context.go('/info-pages');
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Erreur').toString()
          : 'Erreur';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AdminColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminInfoPageCategoriesProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: _isEdit ? 'Modifier la page' : 'Nouvelle page d\'information',
          actions: [
            OutlinedButton(
              onPressed: () => context.go('/info-pages'),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
        Expanded(
          child: (_isEdit && !_initialFetched && _isLoading)
              ? const LoadingView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colonne édition
                        Expanded(
                          flex: 3,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Informations',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 16),
                                  categoriesAsync.when(
                                    loading: () => const LinearProgressIndicator(),
                                    error: (e, _) => Text(
                                      'Thèmes indisponibles : $e',
                                      style: const TextStyle(
                                        color: AdminColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                    data: (categories) => DropdownButtonFormField<int?>(
                                      value: _categoryId,
                                      decoration: const InputDecoration(
                                        labelText: 'Thème',
                                      ),
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('Sans thème'),
                                        ),
                                        for (final category in categories)
                                          DropdownMenuItem<int?>(
                                            value: category.id,
                                            child: Text(category.name),
                                          ),
                                      ],
                                      onChanged: (value) =>
                                          setState(() => _categoryId = value),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _titleCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Titre *'),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Requis'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _slugCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Slug *',
                                              helperText:
                                                  'lettres minuscules, chiffres et tirets'),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return 'Requis';
                                            }
                                            if (!RegExp(r'^[a-z0-9-]+$')
                                                .hasMatch(v)) {
                                              return 'Format invalide';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _menuLabelCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Libellé menu *'),
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? 'Requis'
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          controller: _sortOrderCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'Ordre'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: _isPublished,
                                    onChanged: (v) =>
                                        setState(() => _isPublished = v),
                                    activeColor: AdminColors.primaryDark,
                                    title: const Text('Page publiée'),
                                    subtitle: const Text(
                                      'Décochez pour mettre la page en brouillon',
                                      style: TextStyle(
                                          color: AdminColors.textMuted,
                                          fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Contenu HTML',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _contentCtrl,
                                    maxLines: 18,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText:
                                          '<h2>Titre</h2><p>Votre contenu HTML…</p>',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Requis'
                                            : null,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Colonne preview
                        Expanded(
                          flex: 2,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.visibility_outlined,
                                          size: 18,
                                          color: AdminColors.primaryDark),
                                      const SizedBox(width: 8),
                                      Text('Aperçu',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AdminColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_titleCtrl.text.isNotEmpty)
                                          Text(_titleCtrl.text,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700)),
                                        const SizedBox(height: 12),
                                        Html(
                                          data: _contentCtrl.text.isEmpty
                                              ? '<p style="color: #9aa8b5">L\'aperçu apparaîtra ici…</p>'
                                              : _contentCtrl.text,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
