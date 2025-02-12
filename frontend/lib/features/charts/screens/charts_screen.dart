import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_webview.dart';
import '../providers/charts_provider.dart';
import '../../../core/services/logger_service.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  WebViewController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller == null) {
      final chartsState = ref.read(chartsProvider);
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (WebResourceError error) {
              LoggerService.e('WebView error: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadHtmlString(
          _generateChartHtml(),
          baseUrl: 'https://tradingview.com',
        );
      LoggerService.d('WebViewController initialized');
    }
  }

  String _generateChartHtml() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return '''
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="margin:0;">
          <div class="tradingview-widget-container" style="height:100vh;">
            <div id="tradingview_widget" style="height:100%;"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
            <script type="text/javascript">
            new TradingView.widget({
              "width": "100%",
              "height": "100%",
              "symbol": "BINANCE:BTCUSDT",
              "interval": "D",
              "theme": "${isDarkMode ? 'dark' : 'light'}",
              "container_id": "tradingview_widget",
              "timezone": "exchange",
              "toolbar_bg": "${isDarkMode ? '#1E222D' : '#f1f3f6'}",
              "enable_publishing": false,
              "hide_top_toolbar": false,
              "hide_legend": true,
              "save_image": false,
              "locale": "ru",
              "allow_symbol_change": true
            });
            </script>
          </div>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWebView(controller: controller!);
  }
}
