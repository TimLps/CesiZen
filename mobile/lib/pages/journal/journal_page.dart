import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/journal_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../services/emotion_service.dart';
import '../../widgets/cesi_emoji.dart';
import '../../widgets/state_views.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 6));
  DateTime _to = DateTime.now();
  DateTime _historyDate = DateTime.now();

  String _api(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 56, color: CesiColors.textMuted),
                const SizedBox(height: 16),
                Text('Compte requis',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour suivre votre journal d\'émotions',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CesiColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal d\'émotions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Bloc Rapport par plage ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CesiColors.primary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rapport par plage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 16),
                _DatePickerRow(
                  label: 'Début',
                  date: _from,
                  onPick: () async {
                    final d = await _pick(_from);
                    if (d != null) setState(() => _from = d);
                  },
                ),
                const SizedBox(height: 8),
                _DatePickerRow(
                  label: 'Fin',
                  date: _to,
                  onPick: () async {
                    final d = await _pick(_to);
                    if (d != null) setState(() => _to = d);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ref.invalidate(journalReportProvider(ReportQuery(
                          from: _api(_from), to: _api(_to))));
                      _showRangeReport(context);
                    },
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Bloc Historique par jour ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CesiColors.cardBgSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historique par jour',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 16),
                _DatePickerRow(
                  label: '',
                  date: _historyDate,
                  onPick: () async {
                    final d = await _pick(_historyDate);
                    if (d != null) setState(() => _historyDate = d);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Liste des entrées du jour sélectionné ─────────────────────
          _DayEntries(date: _historyDate),
        ],
      ),
    );
  }

  Future<DateTime?> _pick(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
  }

  void _showRangeReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer(
          builder: (context, ref, _) {
            final reportAsync = ref.watch(journalReportProvider(
                ReportQuery(from: _api(_from), to: _api(_to))));
            return reportAsync.when(
              loading: () => const SizedBox(height: 200, child: LoadingView()),
              error: (e, _) =>
                  SizedBox(height: 200, child: ErrorView(error: e)),
              data: (report) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Du ${DateFormat('dd MMM', 'fr_FR').format(_from)} au ${DateFormat('dd MMM', 'fr_FR').format(_to)}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('${report.totalEntries} entrée(s)',
                      style: const TextStyle(color: CesiColors.textSecondary)),
                  const SizedBox(height: 20),
                  ...report.byCategory.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(int.parse(
                                    'FF${c.colorHex.replaceFirst('#', '')}',
                                    radix: 16)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(c.name)),
                            Text('${c.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onPick;

  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label,
                style: const TextStyle(
                    color: CesiColors.textSecondary, fontSize: 13)),
          ),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(date)),
                ),
                const Icon(Icons.calendar_today_outlined,
                    color: CesiColors.primaryDark, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayEntries extends ConsumerWidget {
  final DateTime date;
  const _DayEntries({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayString = DateFormat('yyyy-MM-dd').format(date);
    final entriesAsync = ref.watch(journalEntriesProvider(
        JournalQuery(from: dayString, to: dayString)));

    return entriesAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.all(32), child: LoadingView()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: ErrorView(error: e),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: EmptyView(
              message: 'Aucune émotion enregistrée ce jour',
              icon: Icons.calendar_today_outlined,
            ),
          );
        }
        return Column(
          children: entries.map((e) => _EntryTile(entry: e)).toList(),
        );
      },
    );
  }
}

class _EntryTile extends ConsumerWidget {
  final JournalEntry entry;
  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = entry.emotion?.category != null
        ? entry.emotion!.category!.color
        : CesiColors.primary;
    final emoji = cesiEmotionFromCategoryName(entry.emotion?.category?.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showEntryDetail(context, ref, entry),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CesiEmoji(emotion: emoji, size: 44, tintColor: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.emotion?.name ?? 'Émotion',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (entry.emotion?.category?.name != null)
                      Text(
                        entry.emotion!.category!.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CesiColors.textSecondary,
                        ),
                      ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entry.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CesiColors.textMuted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                DateFormat('HH:mm').format(entry.displayMoment.toLocal()),
                style: const TextStyle(
                  fontSize: 12,
                  color: CesiColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: CesiColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POPUP RÉCAPITULATIF d'une entrée de journal
// ─────────────────────────────────────────────────────────────────────────────

void _showEntryDetail(BuildContext context, WidgetRef ref, JournalEntry entry) {
  showDialog<void>(
    context: context,
    builder: (dialogCtx) => _EntryDetailDialog(entry: entry, parentRef: ref),
  );
}

class _EntryDetailDialog extends StatelessWidget {
  final JournalEntry entry;
  final WidgetRef parentRef;
  const _EntryDetailDialog({required this.entry, required this.parentRef});

  @override
  Widget build(BuildContext dialogContext) {
    final category = entry.emotion?.category;
    final color = category?.color ?? CesiColors.azurPastel;
    final emoji = cesiEmotionFromCategoryName(category?.name);
    final felt = entry.displayMoment.toLocal();
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(felt);
    final timeStr = DateFormat('HH:mm').format(felt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header coloré avec emoji + catégorie ─────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  CesiEmoji(emotion: emoji, size: 90, tintColor: color),
                  const SizedBox(height: 12),
                  Text(
                    entry.emotion?.name ?? 'Émotion',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (category?.name != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Catégorie : ${category!.name}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: CesiColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Corps : date, heure, note ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: _capitalize(dateStr)),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.schedule, label: 'Heure du ressenti', value: timeStr),
                  const SizedBox(height: 14),
                  const Text(
                    'Note personnelle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CesiColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CesiColors.cardBgSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (entry.note != null && entry.note!.isNotEmpty)
                          ? entry.note!
                          : 'Aucune note pour cette entrée.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: entry.note != null && entry.note!.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                        color: entry.note != null && entry.note!.isNotEmpty
                            ? CesiColors.textPrimary
                            : CesiColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Actions ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      final ok = await showDialog<bool>(
                        context: dialogContext,
                        builder: (confirmCtx) => AlertDialog(
                          title: const Text('Supprimer cette entrée ?'),
                          content: const Text('Cette action est définitive.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(confirmCtx).pop(false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(confirmCtx).pop(true),
                              child: const Text('Supprimer',
                                  style: TextStyle(color: CesiColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await parentRef
                            .read(journalServiceProvider)
                            .delete(entry.id);
                        invalidateJournalViews(parentRef);
                      }
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: CesiColors.error, size: 18),
                    label: const Text('Supprimer',
                        style: TextStyle(color: CesiColors.error)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: CesiColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CesiColors.textSecondary,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
