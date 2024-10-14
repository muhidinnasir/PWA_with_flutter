// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onlinecourse/helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class OpenURLPage extends StatefulWidget {
  final String url;
  final String username;
  final String password;

  const OpenURLPage(
      {super.key,
      required this.url,
      required this.username,
      required this.password});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions(context);
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> performLogin(
      String url, String username, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      await inAppWebViewController.evaluateJavascript(source: """
        var usernameField = document.querySelector('input[name="email"]');
        if (usernameField) {
          usernameField.value = '$username';
        }
        var passwordField = document.querySelector('input[name="password"]');
        if (passwordField) {
          passwordField.value = '$password';
        }
        var form = document.querySelector('form');
        if (form) {
          form.submit();
        }
      """);
    } catch (e) {
      print('Error performing login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Text('Please check your internet connection and try again.'),
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
                initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useOnDownloadStart: true,
                    javaScriptEnabled: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                },
                onDownloadStartRequest: (controller, url) async {
                  String urlString = url.url.toString();
                  if (urlString.startsWith('blob:')) {
                    urlString = urlString.replaceFirst('blob:', '');
                  }
                  await _downloadFile(urlString, context);
                },
                onLoadStop: (controller, url) async {
                  if (url.toString().contains("login")) {
                    await performLogin(
                        widget.url, widget.username, widget.password);
                  }
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

  Future<void> _downloadFile(String url, BuildContext context) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        var dir = await getExternalStorageDirectory();
        var filePath = '${dir!.path}/${url.split('/').last}';
        var file = File(filePath);
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $filePath')),
        );
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file')),
      );
    }
  }
}
