import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';

class NewsFilters extends ConsumerWidget {
  const NewsFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildFilterChip(
            context: context,
            label: 'All',
            selected: selectedCategory.isEmpty,
            onSelected: (_) =>
                ref.read(selectedCategoryProvider.notifier).state = '',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'Crypto',
            selected: selectedCategory == 'crypto',
            onSelected: (_) =>
                ref.read(selectedCategoryProvider.notifier).state = 'crypto',
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Forex'),
            selected: selectedCategory == 'forex',
            onSelected: (_) =>
                ref.read(selectedCategoryProvider.notifier).state = 'forex',
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Stocks'),
            selected: selectedCategory == 'stocks',
            onSelected: (_) =>
                ref.read(selectedCategoryProvider.notifier).state = 'stocks',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ),
      selected: selected,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      checkmarkColor: theme.colorScheme.onPrimary,
      onSelected: onSelected,
    );
  }
}
