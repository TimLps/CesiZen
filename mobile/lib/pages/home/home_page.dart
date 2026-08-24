import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/journal_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/transient_emotion_provider.dart';
import '../../widgets/cesi_emoji.dart';
import '../../widgets/cesi_logo.dart';
import '../../widgets/state_views.dart';

/// Fenêtre durant laquelle l'émotion la plus récente est considérée encore
/// "valide" pour être affichée à l'accueil. Au-delà, on incite à en saisir
/// une nouvelle (cf. spec : 6 heures).
const Duration kFreshEmotionWindow = Duration(hours: 6);

/// Cooldown strict entre deux saisies d'émotion (cf. spec : 5 minutes).
/// Note : ce cooldown est aussi appliqué côté API (HTTP 429) — la valeur
/// ici sert uniquement à donner un retour visuel anticipé à l'utilisateur.
const Duration kEmotionCooldown = Duration(minutes: 5);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const CesiLogo(size: 36),
            const SizedBox(width: 10),
            Text(
              'CESI Zen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
        actions: [
          if (!auth.isAuthenticated)
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Connexion'),
            ),
        ],
      ),
      body: auth.isAuthenticated
          ? const _AuthenticatedHome()
          : const _VisitorHome(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VISITEUR ANONYME
// ─────────────────────────────────────────────────────────────────────────────

class _VisitorHome extends ConsumerWidget {
  const _VisitorHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transient = ref.watch(transientEmotionProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          if (transient == null) ...[
            _CenterEmoji(
              emotion: CesiEmotion.plus,
              onTap: () => context.push('/quick-emotion'),
              tint: CesiColors.azurPastel,
              semanticsLabel: 'Saisir une émotion',
            ),
            const SizedBox(height: 24),
            const Text(
              'Comment vous sentez-vous ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Touchez l\'emoji pour partager votre ressenti.\nCréez un compte pour conserver votre journal.',
              style: TextStyle(color: CesiColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            _CenterEmoji(
              emotion: cesiEmotionFromCategoryName(transient.category.name),
              tint: transient.category.color,
              onTap: () => _onEmojiTap(context, ref, transient.createdAt, isAuthed: false),
              semanticsLabel: 'Émotion ressentie : ${_displayLabel(transient.emotion.feelingLabel ?? transient.category.feelingLabel ?? transient.emotion.name)}',
            ),
            const SizedBox(height: 24),
            Text(
              'Vous vous sentez ${_displayLabel(transient.emotion.feelingLabel ?? transient.category.feelingLabel ?? transient.emotion.name)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Saisi il y a ${_relativeTime(transient.createdAt)}.\nNon enregistré (vous êtes anonyme).',
              style: const TextStyle(color: CesiColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login),
            label: const Text('Se connecter pour sauvegarder'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILISATEUR CONNECTÉ
// ─────────────────────────────────────────────────────────────────────────────

class _AuthenticatedHome extends ConsumerWidget {
  const _AuthenticatedHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastAsync = ref.watch(lastJournalEntryProvider);
    final topAsync = ref.watch(top24hProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(lastJournalEntryProvider);
        ref.invalidate(top24hProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          lastAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: LoadingView(),
            ),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(lastJournalEntryProvider),
            ),
            data: (entry) => _buildHero(context, ref, entry),
          ),
          const SizedBox(height: 36),
          // ── Top 3 24h ────────────────────────────────────────────────
          _Top24hSection(asyncReport: topAsync),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => context.push('/journal'),
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('Voir mon journal et mes rapports'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, WidgetRef ref, JournalEntry? entry) {
    final ts = entry?.displayMoment;
    final isFresh = ts != null && DateTime.now().difference(ts) < kFreshEmotionWindow;

    if (entry == null || !isFresh) {
      return _PlaceholderHero(
        onTap: () => _onEmojiTap(context, ref, null, isAuthed: true),
      );
    }

    final cat = entry.emotion?.category;
    final emo = entry.emotion;
    final categoryName = cat?.name ?? '';
    final tint = cat?.color ?? CesiColors.azurPastel;
    final feelingLabel = _displayLabel(
      emo?.feelingLabel ?? cat?.feelingLabel ?? emo?.name ?? categoryName,
    );

    return Column(
      children: [
        _CenterEmoji(
          emotion: cesiEmotionFromCategoryName(categoryName),
          tint: tint,
          onTap: () => _onEmojiTap(context, ref, entry.createdAt ?? ts, isAuthed: true),
          semanticsLabel: 'Émotion ressentie : $feelingLabel',
        ),
        const SizedBox(height: 24),
        Text(
          'Vous vous sentez $feelingLabel',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Dernière saisie il y a ${_relativeTime(ts)}.',
          style: const TextStyle(color: CesiColors.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        if (entry.note != null && entry.note!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CesiColors.cardBgSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.note!,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION TOP 3 SUR 24H
// ─────────────────────────────────────────────────────────────────────────────

class _Top24hSection extends StatelessWidget {
  final AsyncValue<WindowReport> asyncReport;
  const _Top24hSection({required this.asyncReport});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Vos émotions des 24 dernières heures',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        asyncReport.when(
          loading: () => const SizedBox(
            height: 130,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const _Top3Placeholder(items: []),
          data: (report) => _Top3Row(items: report.byCategory),
        ),
      ],
    );
  }
}

class _Top3Row extends StatelessWidget {
  final List<ReportCategoryItem> items;
  const _Top3Row({required this.items});

  @override
  Widget build(BuildContext context) {
    // Spec : si <3 émotions, on remplit avec des "visages neutres gris" et
    // on n'affiche pas de pourcentage pour ces cases.
    final cells = <Widget>[];
    for (var i = 0; i < 3; i++) {
      if (i < items.length) {
        cells.add(_Top3Cell.fromItem(items[i]));
      } else {
        cells.add(const _Top3Cell.empty());
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [for (final c in cells) Expanded(child: c)],
    );
  }
}

class _Top3Placeholder extends StatelessWidget {
  final List<ReportCategoryItem> items;
  const _Top3Placeholder({required this.items});

  @override
  Widget build(BuildContext context) => _Top3Row(items: items);
}

class _Top3Cell extends StatelessWidget {
  final ReportCategoryItem? item;
  const _Top3Cell.fromItem(ReportCategoryItem this.item);
  const _Top3Cell.empty() : item = null;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = item == null;
    final tint = isPlaceholder
        ? CesiColors.borderSoft
        : Color(int.parse('FF${item!.colorHex.replaceFirst('#', '')}', radix: 16));
    final cesiEmotion = isPlaceholder
        ? CesiEmotion.neutral
        : cesiEmotionFromCategoryName(item!.name);

    return Semantics(
      label: isPlaceholder
          ? 'Pas assez de données pour cette position'
          : '${item!.name} : ${item!.percentage.toStringAsFixed(0)} pour cent',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: isPlaceholder ? 0.55 : 1,
            child: ExcludeSemantics(
              child: CesiEmoji(emotion: cesiEmotion, size: 76, tintColor: tint),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPlaceholder ? '—' : '${item!.percentage.toStringAsFixed(0)} %',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isPlaceholder ? CesiColors.textMuted : CesiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isPlaceholder ? '' : item!.name,
            style: const TextStyle(
              fontSize: 12,
              color: CesiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER QUAND PAS D'ÉMOTION FRAÎCHE
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceholderHero extends StatelessWidget {
  final VoidCallback onTap;
  const _PlaceholderHero({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CenterEmoji(
          emotion: CesiEmotion.plus,
          tint: CesiColors.azurPastel,
          onTap: onTap,
          semanticsLabel: 'Saisir une nouvelle émotion',
        ),
        const SizedBox(height: 24),
        const Text(
          'Comment vous sentez-vous ?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Touchez l\'emoji pour ajouter une nouvelle émotion à votre journal.',
          style: TextStyle(color: CesiColors.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIQUE COOLDOWN STRICT 5 MIN (anticipé côté client)
// ─────────────────────────────────────────────────────────────────────────────

void _onEmojiTap(
  BuildContext context,
  WidgetRef ref,
  DateTime? lastEntryTs, {
  required bool isAuthed,
}) {
  if (lastEntryTs != null) {
    final elapsed = DateTime.now().difference(lastEntryTs);
    if (elapsed < kEmotionCooldown) {
      final remaining = kEmotionCooldown - elapsed;
      final secondsLeft = remaining.inSeconds;
      final mins = secondsLeft ~/ 60;
      final secs = secondsLeft % 60;
      final label = mins > 0
          ? '$mins min ${secs.toString().padLeft(2, '0')} s'
          : '$secs s';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CesiColors.warning,
          content: Text('Patientez encore $label avant une nouvelle saisie.'),
        ),
      );
      return;
    }
  }
  context.push('/quick-emotion');
}

// ─────────────────────────────────────────────────────────────────────────────
// UI helpers
// ─────────────────────────────────────────────────────────────────────────────

class _CenterEmoji extends StatelessWidget {
  final CesiEmotion emotion;
  final Color tint;
  final VoidCallback onTap;
  final String semanticsLabel;

  const _CenterEmoji({
    required this.emotion,
    required this.tint,
    required this.onTap,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ExcludeSemantics(
                child: CesiEmoji(emotion: emotion, size: 200, tintColor: tint),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _displayLabel(String label) {
  if (label.isEmpty) return label;
  // Normalisation : on baisse la première lettre car la phrase
  // "Vous vous sentez X" attend X en minuscule (sauf si déjà capitalisé spécifiquement)
  return label[0].toLowerCase() + label.substring(1);
}

String _relativeTime(DateTime ts) {
  final d = DateTime.now().difference(ts);
  if (d.inMinutes < 1) return 'quelques secondes';
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  if (d.inHours < 24) return '${d.inHours} h';
  return '${d.inDays} j';
}
