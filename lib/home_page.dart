import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'internet_check.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progress = 0;
  late InAppWebViewController _webViewController;
  late StreamSubscription<bool> _internetStatusSubscription;
  bool _hasInternet = false;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
    _internetStatusSubscription =
        checkInternetConnection().listen((hasInternet) {
      setState(() {
        _hasInternet = hasInternet;
      });
    });
  }

  Future<void> _initializeSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _internetStatusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: _hasInternet ? _buildWebView() : _buildNoConnectionScreen(),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: Uri.parse(Uri.encodeFull("http://bloomtravelme.com")),
          ),
          onWebViewCreated: (controller) => _webViewController = controller,
          initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(
              domStorageEnabled: true,
              databaseEnabled: true,
            ),
          ),
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;
            if (url == null) return NavigationActionPolicy.ALLOW;
            if (url.scheme == "http" || url.scheme == "https") {
              // Allow HTTP/HTTPS URLs to load in WebView
              return NavigationActionPolicy.ALLOW;
            }
            // Handle deep links or URLs for other apps
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
        if (_progress < 1)
          LinearProgressIndicator(value: _progress, color: Colors.green),
      ],
    );
  }

  Widget _buildNoConnectionScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green),
          SizedBox(height: 16),
          Icon(Icons.error, color: Colors.red),
          SizedBox(height: 8.0),
          Text('No Internet Connection'),
        ],
      ),
    );
  }
}
