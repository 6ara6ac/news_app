import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/bottom_nav.dart';
import '../../news/screens/news_screen.dart';
import '../../charts/screens/charts_screen.dart';
import '../../quotes/screens/quotes_screen.dart';
import '../../indicators/screens/indicators_screen.dart';
import '../../demo/screens/demo_account_screen.dart';
import '../../../core/providers/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
    4: GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isDarkMode = ref.watch(themeProvider);

    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[currentIndex]!.currentState!.maybePop();
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(currentIndex)),
          centerTitle: true,
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildOffstageNavigator(0, const NewsScreen()),
            _buildOffstageNavigator(1, const ChartsScreen()),
            _buildOffstageNavigator(2, const QuotesScreen()),
            _buildOffstageNavigator(3, const IndicatorsScreen()),
            _buildOffstageNavigator(4, const DemoAccountScreen()),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
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
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index, Widget child) {
    return Offstage(
      offstage: ref.watch(bottomNavIndexProvider) != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => child,
          );
        },
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Новости';
      case 1:
        return 'Графики';
      case 2:
        return 'Котировки';
      case 3:
        return 'Индикаторы';
      case 4:
        return 'Демо счет';
      default:
        return '';
    }
  }
}
