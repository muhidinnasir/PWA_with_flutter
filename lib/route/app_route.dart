import 'package:flutter/material.dart';
import '../splash_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash_screen';
  static const String homeScreen = '/homeScreen';

  static Map<String, WidgetBuilder> get routes => {
        splashScreen: SplashScreen.builder,
      };
}
