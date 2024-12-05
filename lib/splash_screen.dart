import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  static Widget builder(BuildContext context) {
    return const SplashScreen();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    identifyUser();
  }

  identifyUser() {
    // Future.delayed(const Duration(milliseconds: 3000), () {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => WebViewScreen(),
    //       ),
    //       (route) => false);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Image.asset(
                    "assets/play_store_512.png",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
