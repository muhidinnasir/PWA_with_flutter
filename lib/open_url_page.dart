import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class OpenURLPage extends StatefulWidget {
  final String url;

  const OpenURLPage({super.key, required this.url});

  @override
  State<OpenURLPage> createState() => _OpenURLPageState();
}

class _OpenURLPageState extends State<OpenURLPage> {
  double _progress = 0;
  bool hasInternet = false;
  late InAppWebViewController inAppWebViewController;
  StreamSubscription? streamSubscription;
  checkInternet() {
    streamSubscription = InternetConnectionChecker().onStatusChange.listen(
      (event) {
        setState(() {
          hasInternet = event == InternetConnectionStatus.connected;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    // Validate the URL
    if (!Uri.parse(widget.url).isAbsolute) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text(
            'Invalid URL',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Text('The URL provided is not valid.'),
        ),
      );
    }
    if (!hasInternet) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text(
            'Internet Connection',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Internet Connection is not available'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        var isLastPage = await inAppWebViewController.canGoBack();
        if (isLastPage) {
          inAppWebViewController.goBack();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(widget.url),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
              ),
              _progress < 1
                  ? LinearProgressIndicator(
                      value: _progress,
                      color: Colors.green,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
