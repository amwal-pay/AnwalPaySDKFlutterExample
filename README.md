# Amwal Pay SDK Flutter Example

This repository demonstrates how to integrate and use the Amwal Pay SDK in a Flutter application. The Amwal Pay SDK provides a seamless payment experience with support for various payment methods including card payments, wallet payments, NFC, Apple Pay, and Google Pay.

## Features

- Multiple payment methods support (Card, Wallet, NFC, Apple Pay)
- Multiple environment support (SIT, UAT, PROD)
- Multi-language support (Arabic and English)
- Secure payment processing
- Session token management
- Customer ID management

## Installation

1. Add the Amwal Pay SDK dependency to your `pubspec.yaml`:

```yaml
dependencies:
  amwal_pay_sdk: any  # This will use the latest version
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

// This GetSDKSessionToken is to be generated from our backend by your backend. The API call to be made is documented in step 3 
final sessionToken = await getSDKSessionToken(
  merchantId: 'YOUR_MERCHANT_ID',
  secureHashValue: 'YOUR_SECURE_HASH',
  customerId: 'OPTIONAL_CUSTOMER_ID', //This is optional, only to be used when saved card functionality is being used.
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
    merchantReference: 'optional-merchant-reference', // Optional: Merchant reference for transaction tracking
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
- `TransactionType.appleOrGooglePay`: For Apple Pay (iOS)

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

  ### 3. Getting the SDK Session Token and Calculation of Secure Hash to call the API

# Endpoint to Fetch SDKSessionToken

## Environment URLs

### Stage
- **Base URL**: `https://test.amwalpg.com:14443`
- **Endpoint**: `Membership/GetSDKSessionToken`

### Production
- **Base URL**: `https://webhook.amwalpg.com`
- **Endpoint**: `Membership/GetSDKSessionToken`

---

## Description
This endpoint retrieves the SDK session token.

---

## Headers

| Header        | Value              |
|---------------|--------------------|
| Content-Type  | application/json   |

---

## Sample Request

```json
{
  "merchantId": 22914,
  "customerId": "ed520b67-80b2-4e1a-9b86-34208da10e53",
  "requestDateTime": "2025-02-16T12:43:51Z",
  "secureHashValue": "AFCEA6D0D29909E6ED5900F543739975B17AABA66CF2C89BBCCD9382A0BC6DD7"
}
```
## Sample Response

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "sessionToken": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0..3yAPVR3evEwvIdq808M2uQ..."
  }
}
```

## SecureHash

### Overview
HMAC SHA256 hashing ensures data integrity and authenticity between systems.

---

### Prepare Request

1. Order key-value pairs **alphabetically**.
2. Join by `&`, removing the last `&`.
3. **Do not include** `secureHashValue` in the string.
4. Convert the resulting string to a byte array.
5. Generate a secure random key (at least 64 bits).
6. Concatenate the key and the data byte array.
7. Generate a **SHA256** hash.
8. Send the hash with the request as `secureHashValue`.

---

### Example

```json
{
  "merchantId": 22914,
  "customerId": "ed520b67-80b2-4e1a-9b86-34208da10e53",
  "requestDateTime": "2025-02-16T12:43:51Z",
  "secureHashValue": "AFCEA6D0D29909E6ED5900F543739975B17AABA66CF2C89BBCCD9382A0BC6DD7"
}
```

1. Example String to calculate Secure Hash using SHA-256 when not using customer ID = merchantID=22914&requestDatetime=2025-02-16T12:43:51Z

2. Example String to calculate Secure Hash using SHA-256 when using customer ID = customerID=123&merchantID=22914&requestDatetime=2025-02-16T12:43:51Z
## Best Practices

1. Always use the appropriate environment (SIT/UAT/PROD) for your use case
2. Use the correct TransactionType for your payment method
3. Implement proper error handling for all possible scenarios
4. Store sensitive data securely using Android's security best practices
5. Test thoroughly in the test environment before going to production
6. Keep the SDK updated to the latest version by running `flutter pub upgrade amwal_pay_sdk` regularly
7. Follow the security guidelines provided by Amwal Pay
8. Check for NFC availability before initiating NFC transactions
9. Handle configuration changes and lifecycle events properly


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
