import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_filters.dart';
import '../widgets/news_search.dart';
import '../widgets/news_categories.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);

    return Column(
      children: [
        const NewsSearch(),
        const SizedBox(height: 8),
        const NewsCategories(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: newsState.when(
              data: (news) {
                if (news.isEmpty) {
                  return const Center(
                    child: Text('Нет новостей'),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    return NewsCard(
                      article: news[index],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Ошибка: $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
