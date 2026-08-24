import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/info_page.dart';
import '../../providers/data_providers.dart';
import '../../widgets/state_views.dart';

/// Liste des articles d'un thème donné (slug).
class InfoCategoryPage extends ConsumerWidget {
  final String slug;
  const InfoCategoryPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(infoCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: categoriesAsync.maybeWhen(
          data: (cats) {
            final cat = cats.firstWhere(
              (c) => c.slug == slug,
              orElse: () => const InfoPageCategory(
                id: 0, name: 'Articles', slug: '', sortOrder: 0, isActive: true,
              ),
            );
            return Text(cat.name);
          },
          orElse: () => const Text('Articles'),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(infoCategoriesProvider),
        ),
        data: (categories) {
          final category = categories.firstWhere(
            (c) => c.slug == slug,
            orElse: () => const InfoPageCategory(
              id: 0, name: '', slug: '', sortOrder: 0, isActive: true,
            ),
          );
          if (category.pages.isEmpty) {
            return const EmptyView(
              message: 'Aucun article dans ce thème',
              icon: Icons.article_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(infoCategoriesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: category.pages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final page = category.pages[i];
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.article_outlined,
                          color: CesiColors.primaryDark),
                    ),
                    title: Text(page.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        page.menuLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CesiColors.textSecondary,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: CesiColors.textMuted),
                    onTap: () => context.push('/infos/${page.slug}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
