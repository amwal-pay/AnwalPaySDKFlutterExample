import 'dart:async';

import 'package:amwal_pay_sdk/amwal_pay_sdk.dart';
import 'package:amwal_pay_sdk/amwal_sdk_settings/amwal_sdk_settings.dart';
import 'package:amwal_pay_sdk/core/enums/transaction_type.dart';
import 'package:amwal_pay_sdk/core/networking/constants.dart';
import 'package:amwal_pay_sdk/core/networking/dio_client.dart';
import 'package:amwal_pay_sdk/core/networking/secure_hash_interceptor.dart';
import 'package:amwal_pay_sdk/localization/locale_utils.dart';
// import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:anwalpay/currency_model.dart';
import 'package:anwalpay/drop_down_form.dart';
import 'package:anwalpay/text_form.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: MaterialApp(
        title: 'Amwal pay Demo',
        navigatorObservers: [
          AmwalSdkNavigator.amwalNavigatorObserver,
          // ChuckerFlutter.navigatorObserver
        ],
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blue,
        ),
        home: const DemoScreen(),
      ),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late TextEditingController _currencyController;
  late TextEditingController _amountController;
  late TextEditingController _merchantIdController;
  late TextEditingController _terminalController;
  late TextEditingController _secureHashController;
  late TextEditingController _languageController;
  late TextEditingController _transactionTypeController;
  late TextEditingController _merchantReferenceController;

  late GlobalKey<FormState> _formKey;
  late Environment sdkEnv;

  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    /// card terminal => 6942344
    /// wallet terminal => 68341808775

    _amountController = TextEditingController(text: '1');
    _currencyController = TextEditingController(text: 'OMR');
    _languageController = TextEditingController(text: 'en');
    _transactionTypeController = TextEditingController(text: 'CARD || Wallet');
    _merchantIdController = TextEditingController(text: '84131');
    _terminalController = TextEditingController(text: '811018');
    _secureHashController = TextEditingController(
      text: '8570CEED656C8818E4A7CE04F22206358F272DAD5F0227D322B654675ABF8F83',
    );
    _merchantReferenceController = TextEditingController(text: '1234');
    sdkEnv = Environment.UAT;
  }

  Future<String?> getSDKSessionToken({
    required String merchantId,
    required String secureHashValue,
    String? customerId,
  }) async {
    var webhookUrl = '';

    if (sdkEnv == Environment.SIT) {
      webhookUrl = 'https://test.amwalpg.com:24443/';
    } else if (sdkEnv == Environment.UAT) {
      webhookUrl = 'https://test.amwalpg.com:14443/';
    } else if (sdkEnv == Environment.PROD) {
      webhookUrl = 'https://webhook.amwalpg.com/';
    }

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: webhookUrl,
          headers: {
            'authority': 'localhost',
            'accept': 'text/plain',
            'accept-language': 'en-US,en;q=0.9',
            'content-type': 'application/json',
          },
        ),
      );

      // dio.interceptors.add(ChuckerDioInterceptor());
      // DioClient.dio?.interceptors.add(ChuckerDioInterceptor());

      var sec = SecureHashInterceptor.clearSecureHash(secureHashValue, {
        'merchantId': merchantId,
        'customerId': customerId,
      });
      debugPrint('Request [POST] => URL: ${webhookUrl+SDKNetworkConstants.getSDKSessionToken}');
      debugPrint('Request Headers: ${dio.options.headers}');
      debugPrint('Request Data: {merchantId: $merchantId, secureHashValue: $sec, customerId: $customerId}');
      final response = await dio.post(
        SDKNetworkConstants.getSDKSessionToken,
        data: {
          'merchantId': merchantId,
          'secureHashValue': sec,
          'customerId': customerId,
        },
      );

      debugPrint('Response [${response.statusCode}] => URL: ${SDKNetworkConstants.getSDKSessionToken}');
      debugPrint('Response Data: ${response.data}');

      if (response.data['success']) {
        return response.data['data']['sessionToken'];
      }
    } on DioException catch (e) {
      debugPrint('Full API Error: ${e.response}');

      final errorList = e.response?.data['errorList'];
      final errorMessage =
          (errorList != null) ? errorList.join(',') : 'Unknown error';
      await _showErrorDialog(errorMessage);
      return null;
    } catch (e) {
      await _showErrorDialog('Something Went Wrong');
      return null;
    }
    return null;
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('failed'.translate(context)),
          content: Text(message),
        );
      },
    );
  }

  void _onCustomerId(String? customerId) async {
    final instance = await SharedPreferences.getInstance();
    if (customerId != null) {
      await instance.setString('customer_id', customerId);
    }
  }

  Future<String?> _getCustomerId() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getString('customer_id');
  }

  void _onResponse(String? response) {
    debugPrint(response);
  }

  Future<void> initPayment() async {
    try {
      final valid = _formKey.currentState!.validate();
      if (!valid) return;

      var customerId = await _getCustomerId();

      if (customerId == null || customerId.isEmpty || customerId == "null") {
        customerId = null;
      }
      final sessionToken = await getSDKSessionToken(
        merchantId: _merchantIdController.text,
        secureHashValue: _secureHashController.text,
        customerId: customerId,
      );

      if (sessionToken == null) return;

      await AmwalPaySdk.instance.initSdk(
        settings: AmwalSdkSettings(
          environment: sdkEnv,
          sessionToken: sessionToken ?? '',
          currency: _currencyController.text,
          amount: _amountController.text,
          transactionId: const Uuid().v1(),
          merchantId: _merchantIdController.text,
          terminalId: _terminalController.text,
          locale: Locale(_languageController.text),
          isMocked: false,
          transactionType: _getTransactionType(),
          customerCallback: _onCustomerId,
          customerId: customerId,
          onResponse: _onResponse,
          merchantReference: _merchantReferenceController.text.isNotEmpty ? _merchantReferenceController.text : null,
        ),
      );
    }  catch (e, stackTrace) {
      debugPrint('Error during payment: $e');
      debugPrint('Stack trace: $stackTrace');
      await _showErrorDialog('Something went wrong during payment');
    }  finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TransactionType _getTransactionType() {
    switch (_transactionTypeController.text) {
      case 'NFC':
        return TransactionType.nfc;
      case 'APPLE_PAY':
      case 'GOOGLE_PAY':
        return TransactionType.appleOrGooglePay;
      case 'CARD || Wallet':
      default:
        return TransactionType.cardWallet;
    }
  }

  @override
  void dispose() {
    _languageController.dispose();
    _terminalController.dispose();
    _merchantIdController.dispose();
    _secureHashController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _merchantReferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amwal Pay Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer ID removed')),
              );
              // make toast here

              SharedPreferences.getInstance().then((instance) {
                instance.remove('customer_id');
              });
              // Add your onPressed code here!
            },
          ),
        ],
      ),
      body: SizedBox(
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextForm(
                          title: "Merchant Id",
                          controller: _merchantIdController,
                          isNumeric: true,
                          maxLength: 10,
                        ),
                        TextForm(
                          title: "Terminal Id",
                          controller: _terminalController,
                          isNumeric: true,
                          maxLength: 10,
                        ),
                        TextForm(
                          title: "Amount",
                          controller: _amountController,
                          isNumeric: true,
                          maxLength: 6,
                          validator: (value) {
                            if (double.parse(value!) < 0.001) {
                              return 'Invalid Amount';
                            } else {
                              return null;
                            }
                          },
                        ),
                        DropdownForm<CurrencyModel>(
                          title: 'Currency',
                          options: const [
                            CurrencyModel(name: 'OMR', id: '512'),
                          ],
                          valueMapper: (currency) => currency.name,
                          nameMapper: (currency) => currency.name,
                          initialValue:
                              const CurrencyModel(name: 'OMR', id: '512'),
                          onChanged: (currencyId) {
                            _currencyController.text = currencyId ?? '';
                          },
                        ),
                        DropdownForm<String>(
                          title: 'Language',
                          options: const [
                            'ar',
                            'en',
                          ],
                          valueMapper: (lang) => lang,
                          nameMapper: (lang) => lang,
                          initialValue: 'en',
                          onChanged: (currencyId) {
                            _languageController.text = currencyId ?? '';
                          },
                        ),
                        DropdownForm<String>(
                          title: 'Transaction Type',
                          options: [
                            'NFC',
                            'CARD || Wallet',
                            if (Theme.of(context).platform ==
                                TargetPlatform.iOS)
                              'APPLE_PAY',
                            if (Theme.of(context).platform ==
                                TargetPlatform.android)
                              'GOOGLE_PAY',
                          ],
                          valueMapper: (lang) => lang,
                          nameMapper: (lang) => lang,
                          initialValue: 'CARD || Wallet',
                          onChanged: (type) {
                            _transactionTypeController.text = type ?? '';
                          },
                        ),
                        TextForm(
                          title: "Secret Key",
                          controller: _secureHashController,
                        ),
                        TextForm(
                          title: "Merchant Reference (Optional)",
                          controller: _merchantReferenceController,
                        ),
                        const SizedBox(height: 8),
                        // const Text("Select Environment"),
                        const SizedBox(height: 8),
                        DropdownForm<Environment>(
                            title: 'Select Environment',
                            options: Environment.values,
                            valueMapper: (env) => env.index.toString(),
                            nameMapper: (env) => env.name,
                            initialValue: sdkEnv,
                            onChanged: (type) {
                              if (type == null) return;
                              sdkEnv = Environment.values[int.parse(type)];
                            }),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     border: Border.all(
                        //       color: Colors.grey, // Specify the border color
                        //       width: 2.0, // Specify the border width
                        //     ),
                        //     borderRadius: BorderRadius.circular(
                        //       10,
                        //     ), // Optional: Add rounded corners
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(4.0),
                        //     child: DropdownButton<String>(
                        //       isExpanded: true,
                        //       value: dropdownValue,
                        //       onChanged: (String? newValue) {
                        //         setState(() {
                        //           dropdownValue = newValue!;
                        //           switch (dropdownValue) {
                        //             case 'SIT':
                        //               sdkEnv = Environment.SIT;
                        //               break;
                        //             case 'UAT':
                        //               sdkEnv = Environment.UAT;
                        //               break;
                        //             case 'PROD':
                        //               sdkEnv = Environment.PROD;
                        //               break;
                        //             default:
                        //               sdkEnv = Environment.PROD;
                        //               break;
                        //           }
                        //         });
                        //       },
                        //       items: Environment.values
                        //           .map<DropdownMenuItem<String>>(
                        //               (Environment env) {
                        //         return DropdownMenuItem<String>(
                        //           value: env.name,
                        //           child: Text(env.name),
                        //         );
                        //       }).toList(),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (_timer?.isActive ?? false) _timer?.cancel();
                        _timer = Timer(const Duration(milliseconds: 300),
                            () async => await initPayment());
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Text(
                        'Initiate Payment Demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
