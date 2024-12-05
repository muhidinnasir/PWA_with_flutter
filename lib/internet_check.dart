import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';

Stream<bool> checkInternetConnection() {
  return InternetConnectionChecker().onStatusChange.map((status) {
    return status == InternetConnectionStatus.connected;
  });
}
