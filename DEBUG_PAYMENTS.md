# Debug Payment Mode

## Overview

Debug payment mode allows developers to test purchase flows without actual payment processing. This feature is automatically enabled in debug builds and provides a safe way to test in-app purchases during development.

## Features

### 🔧 Automatic Debug Mode
- **Auto-enabled in debug builds**: No configuration needed
- **Production-safe**: Automatically disabled in release builds
- **Visual indicators**: Debug banners and badges show when active

### 💳 Simulated Purchases
- **No real payments**: All transactions are simulated
- **Configurable success rate**: Test both success and failure scenarios
- **Realistic delays**: Simulates network latency for testing
- **Mock transaction IDs**: Generates unique debug transaction identifiers

### 🎨 UI Indicators
- **Debug badges**: Orange "DEBUG" badges in app bars
- **Warning banners**: Clear indicators that debug mode is active
- **Visual feedback**: Users know when payments are simulated

## Configuration

### Debug Settings (`lib/utils/debug_config.dart`)

```dart
class DebugConfig {
  // Enable/disable debug payments
  static const bool enableDebugPayments = kDebugMode && true;
  
  // Simulate network delay (2 seconds)
  static const Duration debugPaymentDelay = Duration(seconds: 2);
  
  // Success rate (1.0 = always success, 0.8 = 80% success)
  static const double debugPaymentSuccessRate = 1.0;
}
```

### Customization Options

| Setting | Description | Default |
|---------|-------------|---------|
| `enableDebugPayments` | Enable debug mode | `kDebugMode && true` |
| `debugPaymentDelay` | Simulated processing time | `2 seconds` |
| `debugPaymentSuccessRate` | Success probability (0.0-1.0) | `1.0` (always success) |

## How It Works

### 1. Purchase Flow Override
```dart
// InAppPurchaseService automatically detects debug mode
if (DebugConfig.enableDebugPayments) {
  return await _simulateDebugPurchase(product);
}
// Normal IAP flow continues for production
```

### 2. Mock Transaction Generation
```dart
// Generates unique debug transaction IDs
String mockTransactionId = DebugConfig.generateMockTransactionId();
// Example: "debug_txn_1634567890123"
```

### 3. Verification Skip
```dart
// Purchase verification is skipped in debug mode
if (result.purchaseDetails != null && !DebugConfig.enableDebugPayments) {
  // Only verify in production
  final bool isValid = await _purchaseService.verifyPurchase(result.purchaseDetails!);
}
```

## UI Integration

### App Bar Debug Indicator
```dart
title: Row(
  children: [
    Text('Purchase Screen'),
    if (DebugConfig.enableDebugPayments) ...[
      SizedBox(width: 8),
      DebugModeIndicator(), // Orange "DEBUG" badge
    ],
  ],
),
```

### Debug Banner Widget
```dart
// Shows warning banner when debug mode is active
if (DebugConfig.enableDebugPayments)
  DebugPaymentBanner(),
```

## Testing Scenarios

### Success Testing
```dart
// Set success rate to 100%
static const double debugPaymentSuccessRate = 1.0;
```

### Failure Testing
```dart
// Set success rate to 0% to test error handling
static const double debugPaymentSuccessRate = 0.0;
```

### Mixed Testing
```dart
// 80% success rate for realistic testing
static const double debugPaymentSuccessRate = 0.8;
```

## Product Types Supported

- ✅ **VIP Subscriptions**: All tiers (Basic, Premium, Gold)
- ✅ **Point Packages**: All denominations (100-5000 points)
- ✅ **Heart Packages**: All sizes (10-500 hearts)
- ✅ **Consumable Items**: Points, hearts, etc.
- ✅ **Non-Consumable Items**: VIP subscriptions

## Benefits

### 🚀 Development Speed
- **No payment setup required**: Test immediately without payment provider configuration
- **Instant feedback**: No waiting for payment processing
- **Unlimited testing**: No cost for repeated testing

### 🛡️ Safety
- **Production isolation**: Cannot accidentally charge real payments
- **Clear visual feedback**: Always know when in debug mode
- **Automatic detection**: No manual switches to forget

### 🧪 Testing Coverage
- **Error scenarios**: Test payment failures and error handling
- **Edge cases**: Test network timeouts and retry logic
- **UI states**: Test loading, success, and error states

## Production Deployment

Debug mode is automatically disabled in production builds:

- ✅ **Release builds**: Debug payments automatically disabled
- ✅ **App store builds**: No debug code included
- ✅ **Real payments**: Normal IAP flow for actual users

## Log Messages

Debug mode includes detailed logging:

```
[DEBUG] 디버그 모드 구매 시뮬레이션: dating_points_1000
[DEBUG] 디버그 모드 구매 성공 시뮬레이션
[DEBUG] 디버그 모드: 영수증 검증 스킵
```

## Troubleshooting

### Issue: Debug mode not showing
- **Solution**: Ensure you're running a debug build (`flutter run`)
- **Check**: Verify `kDebugMode` is true

### Issue: Payments still processing real transactions  
- **Solution**: Verify `DebugConfig.enableDebugPayments` is true
- **Check**: Look for debug indicators in UI

### Issue: Success rate not working
- **Solution**: Check `debugPaymentSuccessRate` value (0.0-1.0)
- **Test**: Try multiple purchases to see variation

## Future Enhancements

- 📊 **Analytics simulation**: Mock analytics events
- 🔄 **Restore purchases**: Simulate purchase restoration
- 📱 **Platform differences**: iOS vs Android simulation differences
- 🎛️ **Runtime configuration**: Change debug settings without rebuild