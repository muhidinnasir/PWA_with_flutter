import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Branmetron',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progress = 0;
  late InAppWebViewController inAppWebViewController;
  StreamSubscription? streamSubscription;

  bool hasInternet = false;

  initializSplash() async {
    await Future.delayed(const Duration(seconds: 6));
    FlutterNativeSplash.remove();
  }

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
    initializSplash();
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
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
            body: hasInternet
                ? Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                            url: Uri.parse(
                                "https://brainmetron.kibrewosen.com")),
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
                            )
                          : const SizedBox()
                    ],
                  )
                : const Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('No Internet Connection'),
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }
}
