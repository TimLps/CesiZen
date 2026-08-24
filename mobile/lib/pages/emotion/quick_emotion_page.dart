import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/emotion.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/transient_emotion_provider.dart';
import '../../services/emotion_service.dart';
import '../../widgets/cesi_emoji.dart';
import '../../widgets/state_views.dart';

/// Saisie rapide d'une émotion :
/// 1. choix d'une catégorie de base (6 cartes Joie/Colère/...) ;
/// 2. choix optionnel du niveau 2 (chips niveau 2 affichées dynamiquement) ;
/// 3. utilisateurs connectés uniquement : note libre + durée écoulée
///    (« à l'instant » par défaut, ou il y a 5/10/15/30/60 min) ;
/// 4. validation.
///
/// Le cooldown 5 minutes est appliqué côté serveur (HTTP 429). En cas de
/// violation, on affiche un snackbar dédié.
class QuickEmotionPage extends ConsumerStatefulWidget {
  const QuickEmotionPage({super.key});

  @override
  ConsumerState<QuickEmotionPage> createState() => _QuickEmotionPageState();
}

class _QuickEmotionPageState extends ConsumerState<QuickEmotionPage> {
  EmotionCategory? _selectedCategory;
  Emotion? _selectedEmotion;

  /// Durée écoulée depuis le ressenti, en minutes. 0 = à l'instant.
  int _minutesAgo = 0;

  final _noteCtrl = TextEditingController();
  bool _saving = false;

  final _scrollCtrl = ScrollController();
  final _level2Key = GlobalKey();

  static const _durationOptions = <int>[0, 5, 10, 15, 30, 60];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onCategoryTapped(EmotionCategory cat) {
    setState(() {
      _selectedCategory = cat;
      _selectedEmotion = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _level2Key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(emotionCategoriesProvider);
    final isAuthed = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Comment vous sentez-vous ?')),
      body: categoriesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(emotionCategoriesProvider),
        ),
        data: (categories) => _buildBody(context, categories, isAuthed),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<EmotionCategory> categories, bool isAuthed) {
    return ListView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const Text(
          'Choisissez l\'émotion qui vous représente le mieux maintenant.',
          style: TextStyle(fontSize: 15, color: CesiColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // ── Étape 1 : grille des 6 catégories de base ──────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: [
            for (final cat in categories) _CategoryCard(
              category: cat,
              isSelected: _selectedCategory?.id == cat.id,
              onTap: () => _onCategoryTapped(cat),
            ),
          ],
        ),

        // ── Étape 2 : précision niveau 2 (facultative) ─────────────────
        if (_selectedCategory != null && _selectedCategory!.emotions.isNotEmpty) ...[
          const SizedBox(height: 28),
          Padding(
            key: _level2Key,
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Préciser (facultatif)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final emo in _selectedCategory!.emotions)
                ChoiceChip(
                  label: Text(emo.name),
                  selected: _selectedEmotion?.id == emo.id,
                  onSelected: (s) => setState(() {
                    _selectedEmotion = s ? emo : null;
                  }),
                ),
            ],
          ),

          // ── Étape 3 : durée + note (uniquement utilisateurs connectés) ─
          if (isAuthed && _selectedCategory != null) ...[
            const SizedBox(height: 28),
            Text(
              'Quand l\'avez-vous ressentie ?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in _durationOptions)
                  ChoiceChip(
                    label: Text(_formatDuration(m)),
                    selected: _minutesAgo == m,
                    onSelected: (s) {
                      if (s) setState(() => _minutesAgo = m);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Une note ? (facultatif)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ce qui s\'est passé, ce que vous ressentez…',
              ),
            ),
          ],
        ],

        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (_selectedCategory == null || _saving)
                ? null
                : () => _save(isAuthed),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isAuthed ? 'Enregistrer dans mon journal' : 'Valider mon ressenti'),
          ),
        ),
        if (!isAuthed) ...[
          const SizedBox(height: 12),
          const Text(
            'Visiteur anonyme : votre ressenti sera affiché sur l\'accueil mais ne sera pas sauvegardé.\nCréez un compte pour conserver votre journal, ajouter une note ou indiquer une durée.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: CesiColors.textMuted),
          ),
        ],
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes == 0) return 'À l\'instant';
    if (minutes < 60) return 'Il y a $minutes min';
    final hours = minutes ~/ 60;
    return 'Il y a $hours h';
  }

  Future<void> _save(bool isAuthed) async {
    final cat = _selectedCategory!;
    final emo = _selectedEmotion ?? cat.emotions.first;

    setState(() => _saving = true);

    try {
      if (isAuthed) {
        final feltAt = _minutesAgo > 0
            ? DateTime.now().subtract(Duration(minutes: _minutesAgo))
            : DateTime.now();
        await ref.read(journalServiceProvider).create(
              emotionId: emo.id,
              feltAt: feltAt,
              note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            );
        invalidateJournalViews(ref);
      } else {
        ref.read(transientEmotionProvider.notifier).state = TransientEmotion(
          emotion: emo,
          category: cat,
          createdAt: DateTime.now(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CesiColors.success,
            content: Text(
              isAuthed ? 'Émotion enregistrée' : 'Ressenti pris en compte',
            ),
          ),
        );
        context.go('/');
      }
    } on EmotionCooldownException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CesiColors.warning,
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CesiColors.error,
          content: Text('Échec : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final EmotionCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emotion = cesiEmotionFromCategoryName(category.name);
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Émotion ${category.name}',
      child: Material(
        color: isSelected ? CesiColors.lavande : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? CesiColors.primary : CesiColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: CesiEmoji(emotion: emotion, size: 70, tintColor: category.color),
                ),
                const SizedBox(height: 10),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
