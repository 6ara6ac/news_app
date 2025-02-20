import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';

class NewsCategories extends ConsumerWidget {
  const NewsCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isVisible = ref.watch(filterVisibilityProvider);

    if (!isVisible) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Все'),
            selected: selectedCategory.isEmpty,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = '';
              ref.read(newsProvider.notifier).setCategory('');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Крипто'),
            selected: selectedCategory == 'crypto',
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = 'crypto';
              ref.read(newsProvider.notifier).setCategory('crypto');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Форекс'),
            selected: selectedCategory == 'forex',
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = 'forex';
              ref.read(newsProvider.notifier).setCategory('forex');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Акции'),
            selected: selectedCategory == 'stocks',
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = 'stocks';
              ref.read(newsProvider.notifier).setCategory('stocks');
            },
          ),
        ],
      ),
    );
  }
}
