import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ru'));

@immutable
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];

  String get currentLanguage => locale.languageCode;

  String translate(String key) =>
      _localizedValues[locale.languageCode]?[key] ?? key;

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'news': 'Новости',
      'charts': 'Графики',
      // ... другие переводы
    },
    'en': {
      'news': 'News',
      'charts': 'Charts',
      // ... другие переводы
    },
  };
}
