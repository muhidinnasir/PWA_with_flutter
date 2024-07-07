// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onlinecourse/helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions(context);
    });
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
                  print("this before ==> $urlString");
                  if (urlString.startsWith('blob:')) {
                    urlString = urlString.replaceFirst('blob:', '');
                  }
                  // await launchUrl(Uri.parse(urlString));
                  await _downloadFile(urlString, context);
                },
                onLoadStop: (controller, url) async {
                  controller.addJavaScriptHandler(
                    handlerName: 'downloadBlob',
                    callback: (args) async {
                      String base64data = args[0];
                      var dir = await getExternalStorageDirectory();
                      var filePath = '${dir!.path}/downloaded_file';
                      var file = File(filePath);
                      var bytes = base64Decode(base64data.split(',').last);
                      await file.writeAsBytes(bytes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File downloaded to $filePath')),
                      );
                    },
                  );
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
      print(url);
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        var dir = await getExternalStorageDirectory();
        var filePath = '${dir!.path}/${url.split('/').last}';
        var file = File(filePath);
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $filePath')),
        );
      } else {
        print('response.reasonPhrase: ${response.reasonPhrase}');
      }
    } catch (e, s) {
      print('Error downloading: $e ==> $s');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file')),
      );
    }
  }
}
