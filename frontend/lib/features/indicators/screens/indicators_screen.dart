import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/widgets/loading_webview.dart';

class IndicatorsScreen extends StatefulWidget {
  const IndicatorsScreen({super.key});

  @override
  State<IndicatorsScreen> createState() => _IndicatorsScreenState();
}

class _IndicatorsScreenState extends State<IndicatorsScreen> {
  late final WebViewController calendarController;
  late final WebViewController indicatorsController;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    calendarController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_generateCalendarHtml());

    indicatorsController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_generateIndicatorsHtml());
  }

  String _generateCalendarHtml() {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { margin: 0; background-color: #131722; }
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
            <div class="tradingview-widget-container__widget"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-events.js" async>
            {
              "colorTheme": "dark",
              "isTransparent": false,
              "width": "100%",
              "height": "100%",
              "locale": "ru",
              "importanceFilter": "0,1,2",
              "currencyFilter": "USD,EUR,JPY,GBP,CHF,AUD,CAD,NZD,CNY"
            }
            </script>
          </div>
        </body>
      </html>
    ''';
  }

  String _generateIndicatorsHtml() {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { margin: 0; background-color: #131722; }
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
            <div class="tradingview-widget-container__widget"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
            {
              "interval": "1m",
              "width": "100%",
              "isTransparent": false,
              "height": "100%",
              "symbol": "FOREXCOM:SPXUSD",
              "showIntervalTabs": true,
              "locale": "ru",
              "colorTheme": "dark"
            }
            </script>
          </div>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelColor: theme.colorScheme.onSurface,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Календарь',
            ),
            Tab(
              icon: Icon(Icons.show_chart),
              text: 'Технический анализ',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  LoadingWebView(controller: calendarController),
                  LoadingWebView(controller: indicatorsController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
