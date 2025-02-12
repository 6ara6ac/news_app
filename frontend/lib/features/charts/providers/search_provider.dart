import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSymbolsProvider = Provider<List<Map<String, String>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final symbols = [
    {'symbol': 'BINANCE:BTCUSDT', 'name': 'Bitcoin'},
    {'symbol': 'BINANCE:ETHUSDT', 'name': 'Ethereum'},
    {'symbol': 'EURUSD', 'name': 'EUR/USD'},
    {'symbol': 'AAPL', 'name': 'Apple'},
    {'symbol': 'TSLA', 'name': 'Tesla'},
    // Добавьте больше инструментов
  ];

  if (query.isEmpty) return symbols;

  return symbols.where((symbol) {
    return symbol['name']!.toLowerCase().contains(query) ||
        symbol['symbol']!.toLowerCase().contains(query);
  }).toList();
});
