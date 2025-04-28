# Amwal Pay SDK Flutter Example

This repository demonstrates how to integrate and use the Amwal Pay SDK in a Flutter application. The Amwal Pay SDK provides a seamless payment experience with support for various payment methods including card payments, wallet payments, NFC, Apple Pay, and Google Pay.

## Features

- Multiple payment methods support (Card, Wallet, NFC, Apple Pay, Google Pay)
- Multiple environment support (SIT, UAT, PROD)
- Multi-language support (Arabic and English)
- Secure payment processing
- Session token management
- Customer ID management

## Installation

1. Add the Amwal Pay SDK dependency to your `pubspec.yaml`:

```yaml
dependencies:
  amwal_pay_sdk: ^1.0.81
```

2. Run flutter pub get to install the dependency:

```bash
flutter pub get
```

## iOS Configuration

1. Add the following entitlements to your `Runner/Runner.entitlements` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.in-app-payments</key>
    <array>
        <string>merchant.applepay.amwalpay</string>
    </array>
</dict>
</plist>
```

2. For Apple Pay integration, you need to:
   - Register your merchant ID in the Apple Developer Portal
   - Share your merchant identifier with Amwal Pay team
   - Replace `merchant.applepay.amwalpay` in the entitlements file with your registered merchant identifier
   - Ensure your Apple Developer account has Apple Pay capability enabled
   - Configure your payment processing certificate in the Apple Developer Portal

3. Make sure your iOS deployment target is set appropriately in Xcode.

## Android Configuration

1. Ensure your `android/app/build.gradle` has the following configurations:

```gradle
android {
    defaultConfig {
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion 33
        multiDexEnabled true
    }
}
```

2. Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Usage

1. Initialize the SDK in your app:

```dart
import 'package:amwal_pay_sdk/amwal_pay_sdk.dart';
import 'package:amwal_pay_sdk/amwal_sdk_settings/amwal_sdk_settings.dart';
import 'package:amwal_pay_sdk/core/enums/transaction_type.dart';

// Get session token from your backend
final sessionToken = await getSDKSessionToken(
  merchantId: 'YOUR_MERCHANT_ID',
  secureHashValue: 'YOUR_SECURE_HASH',
  customerId: 'OPTIONAL_CUSTOMER_ID',
);

// Initialize the SDK with Apple Pay
await AmwalPaySdk.instance.initSdk(
  settings: AmwalSdkSettings(
    environment: Environment.UAT, // or SIT, PROD
    sessionToken: sessionToken,
    currency: 'OMR',
    amount: '1.0',
    transactionId: const Uuid().v1(),
    merchantId: 'YOUR_MERCHANT_ID',
    terminalId: 'YOUR_TERMINAL_ID',
    locale: const Locale('en'), // or 'ar' for Arabic
    isMocked: false,
    transactionType: TransactionType.appleOrGooglePay, // Use this for Apple Pay
    customerCallback: (String? customerId) {
      // Handle customer ID callback
    },
    customerId: 'OPTIONAL_CUSTOMER_ID',
    onResponse: (String? response) {
      // Handle payment response
    },
  ),
);
```

2. Add the SDK's navigator observer to your MaterialApp:

```dart
MaterialApp(
  navigatorObservers: [
    AmwalSdkNavigator.amwalNavigatorObserver,
  ],
  // ... other configurations
)
```

## Transaction Types

The SDK supports the following transaction types:

- `TransactionType.cardWallet`: For card and wallet payments
- `TransactionType.nfc`: For NFC payments
- `TransactionType.appleOrGooglePay`: For Apple Pay (iOS) or Google Pay (Android)

## Environments

The SDK supports three environments:

- `Environment.SIT`: System Integration Testing
- `Environment.UAT`: User Acceptance Testing
- `Environment.PROD`: Production

## Webhook URLs

The SDK uses different webhook URLs based on the environment:

- SIT: `https://test.amwalpg.com:24443/`
- UAT: `https://test.amwalpg.com:14443/`
- PROD: `https://webhook.amwalpg.com/`

## Error Handling

The SDK provides error handling through the `onResponse` callback. Make sure to implement proper error handling in your application:

```dart
onResponse: (String? response) {
  if (response != null) {
    // Handle successful response
    print('Payment successful: $response');
  } else {
    // Handle error
    print('Payment failed');
  }
}
```

## Security

- Always use HTTPS for API calls
- Keep your secure hash value confidential
- Implement proper session management
- Use appropriate environment for testing and production

## Support

For any issues or questions, please contact Amwal Pay support or refer to their official documentation.

## License

This project is licensed under the terms specified in the LICENSE file.

## Apple Pay Specific Requirements

1. Merchant Registration:
   - Register as an Apple Pay merchant in the Apple Developer Portal
   - Obtain a merchant identifier from Apple
   - Share your merchant identifier with Amwal Pay team for integration

2. Device Requirements:
   - iOS device with Apple Pay capability
   - User must have set up Apple Pay on their device
   - User must have added at least one payment method to Apple Pay

3. Testing:
   - Use sandbox environment for testing
   - Test with sandbox Apple Pay accounts
   - Verify merchant identifier configuration
   - Test on physical devices (Apple Pay may not work in simulators)

4. Production:
   - Ensure your merchant identifier is properly configured in production
   - Verify SSL certificates are valid
   - Test with real Apple Pay accounts before going live
