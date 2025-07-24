import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Stream<bool> get onStatusChanged async* {
    await for (final result in Connectivity().onConnectivityChanged) {
      yield result != ConnectivityResult.none;
    }
  }
} 