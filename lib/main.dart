import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_url_page.dart';

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
      title: 'Radian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AddURLPage(),
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
    await Future.delayed(const Duration(seconds: 3));
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
                        url: Uri.parse("http://168.119.162.153:1111/"),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        inAppWebViewController = controller;
                      },
                      // shouldOverrideUrlLoading:
                      //     (controller, navigationAction) async {
                      //   var url = navigationAction.request.url;
                      //   if (!url.toString().contains('nehabi.ashewa.com')) {
                      //     // Cancel the navigation
                      //     return NavigationActionPolicy.CANCEL;
                      //   } else {
                      //     // Allow the navigation to proceed
                      //     return NavigationActionPolicy.ALLOW;
                      //   }
                      // },
                      // onLoadStart: (controller, url) {
                      //   if (!url.toString().contains('nehabi.ashewa.com')) {
                      //     // Cancel the navigation
                      //     controller.stopLoading();
                      //     // Open the link using your custom method
                      //     _launchUrl(url.toString());
                      //   }
                      // },
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
                    // _progress < 1
                    //     ? Align(
                    //         child: SizedBox(
                    //           height: MediaQuery.of(context).size.height,
                    //           width: MediaQuery.of(context).size.width,
                    //           child: const Center(
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 CircularProgressIndicator(
                    //                   color: Colors.green,
                    //                 ),
                    //                 Row(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.center,
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.center,
                    //                   children: [
                    //                     Padding(
                    //                       padding: EdgeInsets.only(left: 8.0),
                    //                       child: Text(
                    //                           'Page is loading, Please wait...'),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //     : const SizedBox.shrink(),
                  ],
                )
              : const Center(
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
                            child: Text('No Internet Connection'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Open social media
  void _launchUrl(url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
            .then((value) {});
      } else {
        throw 'Could not launch $url';
      }
    } on PlatformException catch (e) {
      if (e.code == 'LAUNCH_FAILED_NO_APP') {
        return;
      }
    } catch (e) {
      return;
    }
  }
}
