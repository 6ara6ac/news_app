import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'core/providers/theme_provider.dart';
import 'package:flutter/services.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: MaterialApp.router(
        title: 'News4Trading',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            elevation: 2,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: isDarkMode ? Colors.black : Colors.white,
              statusBarIconBrightness:
                  isDarkMode ? Brightness.light : Brightness.dark,
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 65,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            elevation: 8,
            indicatorColor: Colors.blue.withOpacity(0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
        routerConfig: appRouter,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
