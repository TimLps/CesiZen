import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/info_page.dart';
import '../../providers/data_providers.dart';
import '../../widgets/state_views.dart';

/// Liste des THÈMES d'articles d'information. L'utilisateur choisit d'abord
/// un thème (cf. CdC §3.1.1 « accès intuitif structuré par des menus clairs »)
/// puis voit les articles de ce thème via InfoCategoryPage.
class InfoListPage extends ConsumerWidget {
  const InfoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(infoCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Informations')),
      body: categoriesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(infoCategoriesProvider),
        ),
        data: (categories) {
          // On ne montre que les thèmes avec au moins un article publié.
          final visible = categories
              .where((c) => c.pages.isNotEmpty)
              .toList();
          if (visible.isEmpty) {
            return const EmptyView(
              message: 'Aucun article disponible pour le moment',
              icon: Icons.article_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(infoCategoriesProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: visible.length,
              itemBuilder: (context, i) => _CategoryCard(category: visible[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final InfoPageCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Thème ${category.name}, ${category.pages.length} article${category.pages.length > 1 ? "s" : ""}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/infos/category/${category.slug}'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CesiColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _iconFor(category.icon),
                    size: 28,
                    color: CesiColors.primaryDark,
                  ),
                ),
                const Spacer(),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.pages.length} article${category.pages.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CesiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String? name) {
    switch (name) {
      case 'bolt_outlined':           return Icons.bolt_outlined;
      case 'emoji_emotions_outlined': return Icons.emoji_emotions_outlined;
      case 'nightlight_outlined':     return Icons.nightlight_outlined;
      case 'directions_run':          return Icons.directions_run;
      case 'group_outlined':          return Icons.group_outlined;
      case 'self_improvement':        return Icons.self_improvement;
      case 'gavel_outlined':          return Icons.gavel_outlined;
      default:                        return Icons.article_outlined;
    }
  }
}
