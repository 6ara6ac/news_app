import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final chartsProvider =
    StateNotifierProvider<ChartsNotifier, ChartsState>((ref) {
  return ChartsNotifier();
});

class ChartsState {
  final String symbol;
  final String interval;

  ChartsState({
    required this.symbol,
    required this.interval,
  });

  ChartsState copyWith({
    String? symbol,
    String? interval,
  }) {
    return ChartsState(
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
    );
  }
}

class ChartsNotifier extends StateNotifier<ChartsState> {
  ChartsNotifier()
      : super(ChartsState(symbol: 'BINANCE:BTCUSDT', interval: 'D')) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final symbol = prefs.getString('chart_symbol') ?? 'BINANCE:BTCUSDT';
    final interval = prefs.getString('chart_interval') ?? 'D';
    state = ChartsState(symbol: symbol, interval: interval);
  }

  Future<void> updateSymbol(String symbol) async {
    state = state.copyWith(symbol: symbol);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chart_symbol', symbol);
  }

  Future<void> updateInterval(String interval) async {
    state = state.copyWith(interval: interval);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chart_interval', interval);
  }
}
