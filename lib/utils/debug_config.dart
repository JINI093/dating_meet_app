import 'package:flutter/foundation.dart';

/// Debug configuration for the app
class DebugConfig {
  /// Enable debug payment mode - allows purchasing without actual payment
  static const bool enableDebugPayments = kDebugMode && true;
  
  /// Debug payment delay (simulates network delay)
  static const Duration debugPaymentDelay = Duration(seconds: 2);
  
  /// Debug payment success rate (0.0 - 1.0, 1.0 = always success)
  static const double debugPaymentSuccessRate = 1.0;
  
  /// Show debug payment options in UI
  static bool get showDebugPaymentOptions => kDebugMode && enableDebugPayments;
  
  /// Generate mock transaction ID for debug purchases
  static String generateMockTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'debug_txn_$timestamp';
  }
}