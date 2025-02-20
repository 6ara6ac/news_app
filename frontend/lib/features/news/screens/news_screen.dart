import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_search.dart';
import '../widgets/news_categories.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(child: NewsSearch()),
                IconButton(
                  icon: Icon(ref.watch(filterVisibilityProvider)
                      ? Icons.filter_list_off
                      : Icons.filter_list),
                  onPressed: () {
                    ref.read(filterVisibilityProvider.notifier).state =
                        !ref.watch(filterVisibilityProvider);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const NewsCategories(),
          Expanded(
            child: newsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Text('Ошибка загрузки: $err'),
              ),
              data: (articles) {
                if (articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Ничего не найдено по запросу "$searchQuery"'
                              : selectedCategory.isNotEmpty
                                  ? 'Нет новостей в категории "${selectedCategory}"'
                                  : 'Нет доступных новостей',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                '';
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(newsProvider.notifier).resetFilters();
                          },
                          child: const Text('Показать все новости'),
                        ),
                      ],
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollEndNotification &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent * 0.8) {
                      ref.read(newsProvider.notifier).loadNews();
                    }
                    return true;
                  },
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(newsProvider.notifier).loadNews(refresh: true),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return NewsCard(article: articles[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
