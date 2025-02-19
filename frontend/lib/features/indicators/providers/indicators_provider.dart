import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/economic_indicator.dart';

final indicatorsProvider = StateNotifierProvider<IndicatorsNotifier,
    AsyncValue<List<EconomicIndicator>>>((ref) {
  return IndicatorsNotifier();
});

class IndicatorsNotifier
    extends StateNotifier<AsyncValue<List<EconomicIndicator>>> {
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  IndicatorsNotifier() : super(const AsyncValue.loading()) {
    loadIndicators();
  }

  Future<void> loadIndicators() async {
    try {
      print('Fetching indicators...');
      final response = await _dio.get('/indicators');
      print('Response status: ${response.statusCode}');
      print('Raw response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List && response.data.isNotEmpty) {
          final indicators = (response.data as List).map((json) {
            print('Processing indicator: $json');
            return EconomicIndicator(
              country: json['country'] ?? 'Unknown',
              interestRate: json['interestRate']?.toDouble() ?? 0.0,
              inflation: json['inflation']?.toDouble() ?? 0.0,
              unemployment: json['unemployment']?.toDouble() ?? 0.0,
            );
          }).toList();

          print('Parsed indicators: $indicators');
          state = AsyncValue.data(indicators);
        } else {
          print('Response data is not a list or is empty');
          state = AsyncValue.data([]);
        }
      } else {
        throw Exception('Failed to load indicators: ${response.statusCode}');
      }
    } catch (e, st) {
      print('Error loading indicators: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
