import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../widgets/state_views.dart';

class InfoDetailPage extends ConsumerWidget {
  final String slug;
  const InfoDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(infoPageProvider(slug));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: pageAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(infoPageProvider(slug)),
        ),
        data: (page) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 18),
              Html(
                data: page.content,
                style: {
                  'body': Style(
                    fontSize: FontSize(15),
                    color: CesiColors.textPrimary,
                    lineHeight: const LineHeight(1.6),
                  ),
                  'h2': Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.w700,
                    color: CesiColors.textPrimary,
                    margin: Margins.only(top: 18, bottom: 8),
                  ),
                  'h3': Style(
                    fontSize: FontSize(17),
                    fontWeight: FontWeight.w600,
                    color: CesiColors.primaryDark,
                    margin: Margins.only(top: 14, bottom: 6),
                  ),
                  'li': Style(margin: Margins.only(bottom: 6)),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
