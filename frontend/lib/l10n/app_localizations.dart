import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ru'));

class AppLocalizations {
  static const supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'news': 'Новости',
      'charts': 'Графики',
      'quotes': 'Котировки',
      'indicators': 'Индикаторы',
      'demo': 'Демо счет',
      'select_instrument': 'Выберите инструмент',
      'select_interval': 'Выберите интервал',
      // ... другие переводы
    },
    'en': {
      'news': 'News',
      'charts': 'Charts',
      'quotes': 'Quotes',
      'indicators': 'Indicators',
      'demo': 'Demo Account',
      'select_instrument': 'Select Instrument',
      'select_interval': 'Select Interval',
      // ... другие переводы
    },
  };
}
