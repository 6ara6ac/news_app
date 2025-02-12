import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/widgets/loading_webview.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_generateQuotesHtml());
  }

  String _generateQuotesHtml() {
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
            <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-market-overview.js" async>
            {
              "colorTheme": "dark",
              "dateRange": "12M",
              "showChart": true,
              "locale": "ru",
              "largeChartUrl": "",
              "isTransparent": false,
              "showSymbolLogo": true,
              "showFloatingTooltip": false,
              "width": "100%",
              "height": "100%",
              "plotLineColorGrowing": "rgba(41, 98, 255, 1)",
              "plotLineColorFalling": "rgba(41, 98, 255, 1)",
              "gridLineColor": "rgba(42, 46, 57, 0)",
              "scaleFontColor": "rgba(219, 219, 219, 1)",
              "belowLineFillColorGrowing": "rgba(41, 98, 255, 0.12)",
              "belowLineFillColorFalling": "rgba(41, 98, 255, 0.12)",
              "belowLineFillColorGrowingBottom": "rgba(41, 98, 255, 0)",
              "belowLineFillColorFallingBottom": "rgba(41, 98, 255, 0)",
              "symbolActiveColor": "rgba(41, 98, 255, 0.12)",
              "tabs": [
                {
                  "title": "Индексы",
                  "symbols": [
                    {
                      "s": "FOREXCOM:SPXUSD",
                      "d": "S&P 500"
                    },
                    {
                      "s": "FOREXCOM:NSXUSD",
                      "d": "NASDAQ 100"
                    },
                    {
                      "s": "FOREXCOM:DJI",
                      "d": "Dow Jones"
                    },
                    {
                      "s": "INDEX:NKY",
                      "d": "Nikkei 225"
                    },
                    {
                      "s": "INDEX:DEU40",
                      "d": "DAX"
                    },
                    {
                      "s": "FOREXCOM:UKXGBP",
                      "d": "FTSE 100"
                    }
                  ]
                },
                {
                  "title": "Фьючерсы",
                  "symbols": [
                    {
                      "s": "CME_MINI:ES1!",
                      "d": "S&P 500"
                    },
                    {
                      "s": "CME:6E1!",
                      "d": "Euro"
                    },
                    {
                      "s": "COMEX:GC1!",
                      "d": "Золото"
                    },
                    {
                      "s": "NYMEX:CL1!",
                      "d": "Нефть WTI"
                    },
                    {
                      "s": "NYMEX:NG1!",
                      "d": "Газ"
                    },
                    {
                      "s": "CBOT:ZC1!",
                      "d": "Кукуруза"
                    }
                  ]
                },
                {
                  "title": "Облигации",
                  "symbols": [
                    {
                      "s": "CBOT:ZB1!",
                      "d": "T-Bond"
                    },
                    {
                      "s": "CBOT:UB1!",
                      "d": "Ultra T-Bond"
                    },
                    {
                      "s": "EUREX:FGBL1!",
                      "d": "Euro Bund"
                    },
                    {
                      "s": "EUREX:FBTP1!",
                      "d": "Euro BTP"
                    },
                    {
                      "s": "EUREX:FGBM1!",
                      "d": "Euro BOBL"
                    }
                  ]
                },
                {
                  "title": "Форекс",
                  "symbols": [
                    {
                      "s": "FX:EURUSD",
                      "d": "EUR/USD"
                    },
                    {
                      "s": "FX:GBPUSD",
                      "d": "GBP/USD"
                    },
                    {
                      "s": "FX:USDJPY",
                      "d": "USD/JPY"
                    },
                    {
                      "s": "FX:USDCHF",
                      "d": "USD/CHF"
                    },
                    {
                      "s": "FX:AUDUSD",
                      "d": "AUD/USD"
                    },
                    {
                      "s": "FX:USDCAD",
                      "d": "USD/CAD"
                    }
                  ]
                }
              ]
            }
            </script>
          </div>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: LoadingWebView(controller: controller),
          ),
        ],
      ),
    );
  }
}
