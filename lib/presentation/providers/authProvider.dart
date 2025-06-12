import 'dart:convert';

import 'package:anet_merchant_app/data/models/merchant_self_login_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/data/services/storage_services.dart';
import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_home_page/merchant_info_model.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anet_merchant_app/main.dart';

class AuthProvider with ChangeNotifier {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _merchantIdController = TextEditingController();
  final TextEditingController _phoneNumberOtpController =
      TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController();

  final MerchantInfoModel _merchantInfo = MerchantInfoModel();
  String? _merchantDbaName;
  final MerchantServices _merchantServices = MerchantServices();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MerchantSelfLoginModel req = MerchantSelfLoginModel();
  AlertService alertService = AlertService();

  dynamic loginResponse;

  GlobalKey<FormState> get formKey => _formKey;
  String get merchantId => _merchantInfo.merchantId ?? 'MER3456789';
  String get merchantDbaName => _merchantDbaName ?? 'N/A';
  String get merchantCity => _merchantInfo.merchantCity ?? 'New York';
  String get merchantAddress => _merchantInfo.merchantAddress ?? '123 Main St';
  TextEditingController get passwordController => _passwordController;
  TextEditingController get merchantIdController => _merchantIdController;
  TextEditingController get phoneNumberOtpController =>
      _phoneNumberOtpController;
  TextEditingController get emailOtpController => _emailOtpController;
  String get phoneNumberOtp => _phoneNumberOtpController.text;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _showPassword = false;
  bool _showEmailOtp = false;
  bool get showEmailOtp => _showEmailOtp;

  bool get isLoggedIn => _isLoggedIn;
  MerchantInfoModel get merchantInfo => _merchantInfo;
  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  bool get showPassword => _showPassword;

  void setMerchantDbaName(String name) {
    _merchantDbaName = name;
    notifyListeners();
  }

  clearOtp() {
    _isOtpSent = false;
    _phoneNumberOtpController.clear();
    _emailOtpController.clear();
    notifyListeners();
  }

  resetAll() {
    _isLoggedIn = false;
    _isLoading = false;
    _isOtpSent = false;
    _showPassword = false;
    _showEmailOtp = false;
    // _merchantIdController.clear();
    // _passwordController.clear();
    // _phoneNumberOtpController.clear();
    _emailOtpController.clear();
  }

  togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  toggleEmailOtpVisibility() {
    _showEmailOtp = !showEmailOtp;
    notifyListeners();
  }

  Function() onPresSendButton() {
    if (formKey.currentState!.validate()) {
      if (!_isOtpSent) {
        _setLoading(true);
        sendMerchantLoginOtp();
        return () {
          // Navigate to the next screen or perform any action
        };
      } else {
        _setLoading(true);
        validateMerchantLoginOtp();
        return () {
          // Default action or no-op
        };
      }
    } else {
      alertService.error(
        'Please fill in all required fields.',
      );
      return () {
        // Default action or no-op
      };
    }
  }

  Future<void> sendMerchantLoginOtp() async {
    req
      ..deviceType = "WEB"
      ..merchantId = _merchantIdController.text
      ..password = _passwordController.text;

    try {
      final res =
          await _merchantServices.merchantSelfLogin(req.sentOtpToJson());
      loginResponse = jsonDecode(res.body);

      if (loginResponse != null &&
          loginResponse['responseCode'] == "00" &&
          res.statusCode == 200) {
        // StorageServices.saveSecureStorage(loginResponse,
        //     userName: _merchantIdController.text,
        //     password: _passwordController.text);
        if (loginResponse['twoFARequired']) {
          _isOtpSent = true;
          alertService.success(
              loginResponse['responseMessage'] ?? 'OTP sent successfully');
        } else {
          _isOtpSent = false;
          alertService
              .error(loginResponse['responseMessage'] ?? 'Failed to Send OTP');
        }
      } else {
        _isOtpSent = false;
        alertService
            .error(loginResponse['responseMessage'] ?? 'Failed to Send OTP');
      }
    } catch (e) {
      alertService
          .error('An error occurred while sending OTP: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> validateMerchantLoginOtp() async {
    req
      ..merchantId = _merchantIdController.text
      ..emailOtp = _emailOtpController.text;

    try {
      final res =
          await _merchantServices.verifyOtp(req.validateEmailOtpToJson());
      var response = jsonDecode(res.body);
      if (res.statusCode == 200) {
        if (response != null && response['errorMessage'] == "Success") {
          _isLoggedIn = true;
          _isOtpSent = false;
          StorageServices.saveSecureStorage(loginResponse,
              userName: _merchantIdController.text,
              password: _passwordController.text);
          loginResponse = null;
          alertService.success(
              response['successMessage'] ?? 'OTP Verified successfully!');
          TokenManager()
              .start(NavigationService.navigatorKey.currentState!.context);
          NavigationService.navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('merchantHomeScreen', (route) => false);
        } else {
          alertService
              .error(response['errorMessage'] ?? 'OTP verification failed');
        }
      } else {
        alertService
            .error(response['errorMessage'] ?? 'OTP verification failed');
      }
    } catch (e) {
      alertService
          .error('An error occurred while verifying OTP: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  saveSecureStorage(decodeData, {String? userName, String? password}) async {
    /// NEW HIVE STORAGE CONTROLS
    var datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String dateStr = datetime.toString();
    BoxStorage secureStorage = BoxStorage();

    decodeData['userName'] = userName;

    secureStorage.saveUserDetails(decodeData, userName: userName);
    secureStorage.save('lastLogin', dateStr);
    secureStorage.save('isLogged', true);
    // secureStorage.save('notificationToken', decodeData.notificationToken);
    if (decodeData['role'].toString() == "MERCHANT") {
      secureStorage.save('merchantStatus', decodeData['status'].toString());
    }

    /// OLD Shared Preferences STORAGE CONTROLS
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('token', decodeData['bearerToken'].toString());

    // pref.setString('userName', decodeData['userName'].toString());
    pref.setString('userName', userName!);
    pref.setString('password', password!);

    pref.setString('role', decodeData['role'].toString());
    pref.setString('lastLogin', dateStr);
    pref.setBool('isLogged', true);
    pref.setString('custId', decodeData['custId'].toString());
    pref.setString('acqMerchantId', decodeData['acqMerchantId'].toString());
    print(decodeData['acqMerchantId'].toString());
    if (decodeData['role'].toString() == "MERCHANT") {
      pref.setString('merchantId', decodeData['merchantId'].toString());

      pref.setString('terminalId', decodeData['terminalId'].toString());
      pref.setString(
          'kycExpiryAlertMsg', decodeData['kycExpiryAlertMsg'].toString());
    }
  }
}
