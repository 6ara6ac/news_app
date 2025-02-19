import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/indicators_provider.dart';

class IndicatorsScreen extends ConsumerWidget {
  const IndicatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicatorsAsync = ref.watch(indicatorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Топ 20 экономик мира'),
      ),
      body: indicatorsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Ошибка загрузки: $err'),
        ),
        data: (indicators) {
          if (indicators.isEmpty) {
            return const Center(
              child: Text('Нет данных'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Страна',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Ставка %',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Инфляция %',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Безработица %',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...indicators.map((indicator) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(indicator.country),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child:
                              Text(indicator.interestRate.toStringAsFixed(1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(indicator.inflation.toStringAsFixed(1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child:
                              Text(indicator.unemployment.toStringAsFixed(1)),
                        ),
                      ],
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
