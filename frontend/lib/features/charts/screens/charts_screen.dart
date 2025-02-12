import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_webview.dart';
import '../providers/charts_provider.dart';
import '../../../core/theme/custom_dropdown.dart';
import '../../../core/localization/app_localizations.dart';
import '../providers/symbol_search_provider.dart';
import '../../../core/services/logger_service.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  WebViewController? controller;

  final List<Map<String, String>> symbols = [
    {'symbol': 'BINANCE:BTCUSDT', 'name': 'Bitcoin'},
    {'symbol': 'BINANCE:ETHUSDT', 'name': 'Ethereum'},
    {'symbol': 'EURUSD', 'name': 'EUR/USD'},
    {'symbol': 'AAPL', 'name': 'Apple'},
    {'symbol': 'TSLA', 'name': 'Tesla'},
  ];

  final List<Map<String, String>> intervals = [
    {'value': '1', 'name': '1 мин'},
    {'value': '5', 'name': '5 мин'},
    {'value': '15', 'name': '15 мин'},
    {'value': '60', 'name': '1 час'},
    {'value': 'D', 'name': 'День'},
    {'value': 'W', 'name': 'Неделя'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller == null) {
      LoggerService.d('Initializing WebViewController');
      final chartsState = ref.read(chartsProvider);
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (WebResourceError error) {
              LoggerService.e('WebView error: ${error.description}');
            },
          ),
        )
        ..loadHtmlString(_generateChartHtml(
          chartsState.symbol,
          chartsState.interval,
        ));
      LoggerService.d('WebViewController initialized');
    }
  }

  void _updateChart() {
    final chartsState = ref.read(chartsProvider);
    controller?.loadHtmlString(_generateChartHtml(
      chartsState.symbol,
      chartsState.interval,
    ));
  }

  String _generateChartHtml(String symbol, String interval) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              margin: 0; 
              background-color: ${isDarkMode ? '#131722' : '#ffffff'}; 
            }
            .tradingview-widget-container { 
              position: fixed;
              top: 0;
              left: 0;
              right: 0;
              bottom: 0;
            }
          </style>
        </head>
        <body>
          <div class="tradingview-widget-container">
            <div id="tradingview_chart"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
            <script type="text/javascript">
              new TradingView.widget({
                "width": "100%",
                "height": "100%",
                "symbol": "$symbol",
                "interval": "$interval",
                "timezone": "Etc/UTC",
                "theme": "${isDarkMode ? 'dark' : 'light'}",
                "style": "1",
                "locale": "${AppLocalizations.of(context).currentLanguage}",
                "toolbar_bg": "${isDarkMode ? '#131722' : '#f1f3f6'}",
                "enable_publishing": false,
                "allow_symbol_change": true,
                "container_id": "tradingview_chart",
                "studies": [
                  "MASimple@tv-basicstudies",
                  "RSI@tv-basicstudies"
                ]
              });
            </script>
          </div>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final chartsState = ref.watch(chartsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDropdownButton<String>(
                      value: chartsState.symbol,
                      items: symbols.map((symbol) {
                        return DropdownMenuItem(
                          value: symbol['symbol'],
                          child: Text(symbol['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(chartsProvider.notifier).updateSymbol(value);
                          _updateChart();
                        }
                      },
                      hint: 'Выберите инструмент',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LoadingWebView(controller: controller!),
            ),
          ],
        ),
      ),
    );
  }
}
