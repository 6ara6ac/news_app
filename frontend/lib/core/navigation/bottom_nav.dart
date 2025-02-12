import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final size = MediaQuery.of(context).size;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
      labelBehavior: size.width > 600
          ? NavigationDestinationLabelBehavior.alwaysShow
          : NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.newspaper),
          label: 'Новости',
        ),
        NavigationDestination(
          icon: Icon(Icons.show_chart),
          label: 'Графики',
        ),
        NavigationDestination(
          icon: Icon(Icons.currency_exchange),
          label: 'Котировки',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics),
          label: 'Индикаторы',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance),
          label: 'Демо счет',
        ),
      ],
    );
  }
}
