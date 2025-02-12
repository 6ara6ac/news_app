import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/news/models/news_article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/news/screens/news_screen.dart';
import '../../features/charts/screens/charts_screen.dart';
import '../../features/quotes/screens/quotes_screen.dart';
import '../../features/indicators/screens/indicators_screen.dart';
import '../../features/demo/screens/demo_account_screen.dart';
import '../navigation/bottom_nav.dart';
import '../providers/theme_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return SafeArea(
          child: ScaffoldWithNavBar(
            currentPath: state.uri.path,
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            child: NewsScreen(
              key: state.pageKey,
            ),
          ),
          routes: [
            GoRoute(
              path: 'news/:id',
              pageBuilder: (context, state) => MaterialPage(
                fullscreenDialog: true,
                child: NewsDetailScreen(
                  article: state.extra as NewsArticle,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/charts',
          builder: (context, state) => const ChartsScreen(),
        ),
        GoRoute(
          path: '/quotes',
          builder: (context, state) => const QuotesScreen(),
        ),
        GoRoute(
          path: '/indicators',
          builder: (context, state) => const IndicatorsScreen(),
        ),
        GoRoute(
          path: '/demo',
          builder: (context, state) => const DemoAccountScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final Widget child;
  final String currentPath;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(widget.currentPath);
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
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
      body: Container(
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        height: kBottomNavigationBarHeight,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
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
    );
  }

  int _calculateSelectedIndex(String currentPath) {
    if (currentPath.startsWith('/news/')) return 0;
    if (currentPath == '/') return 0;
    if (currentPath == '/charts') return 1;
    if (currentPath == '/quotes') return 2;
    if (currentPath == '/indicators') return 3;
    if (currentPath == '/demo') return 4;
    return 0;
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

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/charts');
        break;
      case 2:
        context.go('/quotes');
        break;
      case 3:
        context.go('/indicators');
        break;
      case 4:
        context.go('/demo');
        break;
    }
  }
}
