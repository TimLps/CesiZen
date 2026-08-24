import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/emotion.dart';
import '../../providers/data_providers.dart';
import '../../services/emotion_service.dart';
import '../../widgets/state_views.dart';

class JournalAddEditPage extends ConsumerStatefulWidget {
  final int? entryId;
  const JournalAddEditPage({super.key, this.entryId});

  @override
  ConsumerState<JournalAddEditPage> createState() => _JournalAddEditPageState();
}

class _JournalAddEditPageState extends ConsumerState<JournalAddEditPage> {
  DateTime _date = DateTime.now();
  Emotion? _selected;
  final _noteCtrl = TextEditingController();
  bool _isSaving = false;

  bool get _isEdit => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntry());
    }
  }

  Future<void> _loadEntry() async {
    try {
      final entries =
          await ref.read(journalServiceProvider).list();
      if (!mounted) return;
      final entry = entries.firstWhere(
        (e) => e.id == widget.entryId,
        orElse: () => throw StateError('Entrée introuvable'),
      );
      setState(() {
        _date = entry.date;
        _noteCtrl.text = entry.note ?? '';
      });
      final cats = await ref.read(emotionCategoriesProvider.future);
      if (!mounted) return;
      for (final c in cats) {
        for (final e in c.emotions) {
          if (e.id == entry.emotionId) {
            setState(() => _selected = e);
            return;
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CesiColors.error,
          content: Text('Impossible de charger l\'entrée : $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une émotion')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final svc = ref.read(journalServiceProvider);
      if (_isEdit) {
        await svc.update(
          entryId: widget.entryId!,
          emotionId: _selected!.id,
          date: _date,
          note: _noteCtrl.text.trim(),
        );
      } else {
        await svc.create(
          emotionId: _selected!.id,
          date: _date,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
      }
      ref.invalidate(journalEntriesProvider);
      ref.invalidate(journalReportProvider);
      if (mounted) context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] as String? ?? 'Erreur lors de l\'enregistrement.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: CesiColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(emotionCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier' : 'Nouvelle entrée'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(emotionCategoriesProvider),
        ),
        data: (categories) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              Text('Date', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('fr', 'FR'),
                  );
                  if (d != null) setState(() => _date = d);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEAEEF1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: CesiColors.primaryDark),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(_date)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Comment vous sentez-vous ?',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              ...categories.map((cat) => _CategoryBlock(
                    category: cat,
                    selected: _selected,
                    onSelect: (e) => setState(() => _selected = e),
                  )),
              const SizedBox(height: 16),
              Text('Une note ? (optionnel)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 4,
                maxLength: 2000,
                decoration: const InputDecoration(
                  hintText: 'Décrivez ce que vous avez ressenti…',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(_isEdit ? 'Mettre à jour' : 'Enregistrer'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final EmotionCategory category;
  final Emotion? selected;
  final ValueChanged<Emotion> onSelect;

  const _CategoryBlock({
    required this.category,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.materialIcon,
                    color: CesiColors.textPrimary, size: 22),
                const SizedBox(width: 8),
                Text(category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: category.emotions
                  .where((e) => e.isActive)
                  .map((e) => ChoiceChip(
                        label: Text(e.name),
                        selected: selected?.id == e.id,
                        onSelected: (_) => onSelect(e),
                        backgroundColor: Colors.white,
                        selectedColor: category.color,
                        labelStyle: TextStyle(
                          color: selected?.id == e.id
                              ? CesiColors.textPrimary
                              : CesiColors.textSecondary,
                          fontWeight: selected?.id == e.id
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: category.color),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
