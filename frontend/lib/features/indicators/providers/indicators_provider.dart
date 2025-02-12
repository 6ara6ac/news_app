import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/economic_indicator.dart';

final indicatorsProvider =
    StateNotifierProvider<IndicatorsNotifier, List<EconomicIndicator>>((ref) {
  return IndicatorsNotifier();
});

class IndicatorsNotifier extends StateNotifier<List<EconomicIndicator>> {
  IndicatorsNotifier()
      : super([
          EconomicIndicator(
            country: 'США',
            interestRate: 5.50,
            inflation: 3.40,
            unemployment: 3.70,
          ),
          EconomicIndicator(
            country: 'Китай',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Зона евро',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Германия',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Япония',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Индия',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Великобритания',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Франция',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Италия',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Бразилия',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Канада',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Россия',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          EconomicIndicator(
            country: 'Мексика',
            interestRate: 4.50,
            inflation: 2.90,
            unemployment: 6.40,
          ),
          // Добавьте остальные страны здесь
        ]);
}
