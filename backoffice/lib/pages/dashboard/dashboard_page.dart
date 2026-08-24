import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/admin_theme.dart';
import '../../models/admin_models.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/cesi_emoji.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Tableau de bord',
          subtitle: 'Vue d\'ensemble de la plateforme CESIZen',
          actions: [
            IconButton(
              onPressed: () => ref.invalidate(dashboardStatsProvider),
              icon: const Icon(Icons.refresh),
              tooltip: 'Rafraîchir',
            ),
          ],
        ),
        Expanded(
          child: statsAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(dashboardStatsProvider),
            ),
            data: (stats) => SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _KpiCard(
                        title: 'Utilisateurs',
                        value: stats.usersTotal.toString(),
                        subtitle: '${stats.usersActive} actifs',
                        icon: Icons.people_outline,
                        color: AdminColors.kpiBlue,
                      ),
                      _KpiCard(
                        title: 'Nouveaux (30 j)',
                        value: stats.usersLast30Days.toString(),
                        subtitle: '${stats.usersLast7Days} sur 7 j',
                        icon: Icons.person_add_outlined,
                        color: AdminColors.kpiGreen,
                      ),
                      _KpiCard(
                        title: 'Pages publiées',
                        value: stats.infoPagesPublished.toString(),
                        subtitle: '${stats.infoPagesTotal} au total · ${stats.infoPagesDrafts} brouillons',
                        icon: Icons.article_outlined,
                        color: AdminColors.kpiYellow,
                      ),
                      _KpiCard(
                        title: 'Référentiel d\'émotions',
                        value: stats.emotionsCount.toString(),
                        subtitle:
                            '${stats.emotionCategoriesCount} catégories de base',
                        icon: Icons.emoji_emotions_outlined,
                        color: AdminColors.kpiPink,
                      ),
                      _KpiCard(
                        title: 'Entrées de journal',
                        value: stats.journalEntriesTotal.toString(),
                        subtitle: '${stats.journalEntriesLast7Days} sur 7 j · ${stats.journalEntriesLast30Days} sur 30 j',
                        icon: Icons.menu_book_outlined,
                        color: AdminColors.kpiPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // ── Graphiques ─────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ChartCard(
                          title: 'Activité du journal — 14 derniers jours',
                          child: SizedBox(
                            height: 240,
                            child: _DailyChart(items: stats.daily14d),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: _ChartCard(
                          title: 'Émotions les plus saisies',
                          child: _TopCategoriesList(items: stats.topCategories),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _OverviewCard(stats: stats),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AdminColors.textPrimary, size: 22),
              ),
              const Spacer(),
              Text(value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
            ],
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                color: AdminColors.textSecondary,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final List<DailyEntryItem> items;
  const _DailyChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Aucune donnée pour le moment',
            style: TextStyle(color: AdminColors.textMuted)),
      );
    }
    final df = DateFormat('dd/MM', 'fr_FR');
    final maxY = items.map((e) => e.total).fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY < 4 ? 5 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AdminColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= items.length) return const SizedBox.shrink();
                if (i % 2 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    df.format(items[i].day),
                    style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < items.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: items[i].total.toDouble(),
                color: AdminColors.primary,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]),
        ],
      ),
    );
  }
}

class _TopCategoriesList extends StatelessWidget {
  final List<TopCategoryItem> items;
  const _TopCategoriesList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Aucune entrée pour l\'instant',
              style: TextStyle(color: AdminColors.textMuted)),
        ),
      );
    }
    final maxTotal = items.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final item in items) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Mini-emoji CESI Zen au lieu d'un simple cercle
              CesiEmoji(
                emotion: cesiEmotionFromCategoryName(item.name),
                size: 36,
                tintColor: item.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text('${item.total}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AdminColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxTotal == 0 ? 0 : item.total / maxTotal,
                        minHeight: 5,
                        backgroundColor: AdminColors.border,
                        valueColor: AlwaysStoppedAnimation(item.color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final DashboardStats stats;
  const _OverviewCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('État de la plateforme',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            _OverviewRow(
              label: 'Taux d\'utilisateurs actifs',
              value: stats.usersTotal == 0
                  ? 0.0
                  : (stats.usersActive / stats.usersTotal),
              text: '${stats.usersActive} / ${stats.usersTotal}',
              color: AdminColors.success,
            ),
            const SizedBox(height: 16),
            _OverviewRow(
              label: 'Pages publiées',
              value: stats.infoPagesTotal == 0
                  ? 0.0
                  : (stats.infoPagesPublished / stats.infoPagesTotal),
              text:
                  '${stats.infoPagesPublished} / ${stats.infoPagesTotal}',
              color: AdminColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final double value;
  final String text;
  final Color color;

  const _OverviewRow({
    required this.label,
    required this.value,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AdminColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
