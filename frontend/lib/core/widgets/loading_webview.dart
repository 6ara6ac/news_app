import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoadingWebView extends StatefulWidget {
  final WebViewController controller;

  const LoadingWebView({super.key, required this.controller});

  @override
  State<LoadingWebView> createState() => _LoadingWebViewState();
}

class _LoadingWebViewState extends State<LoadingWebView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        },
        onWebResourceError: (WebResourceError error) {
          // Обрабатываем ошибку загрузки
          print('WebView error: ${error.description}');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          WebViewWidget(
            controller: widget.controller,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
