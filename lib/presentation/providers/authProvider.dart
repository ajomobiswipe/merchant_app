import 'package:anet_merchant_app/core/config.dart';
import 'package:anet_merchant_app/data/models/merchant_self_login_model.dart';
import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/data/services/storage_services.dart';
import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:anet_merchant_app/presentation/pages/forgot_password.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_home_page/merchant_info_model.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:anet_merchant_app/presentation/widgets/logout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // GlobalKey<FormState> get formKey => _formKey;
  String get merchantId => _merchantInfo.merchantId ?? 'MER3456789';
  String get merchantDbaName => _merchantDbaName ?? 'N/A';
  List<dynamic>? get merchantIds => _merchantIds;
  List<dynamic>? _merchantIds;
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
  bool _isRemember = false;
  bool get isRemember => _isRemember;
  bool get showEmailOtp => _showEmailOtp;

  bool get isResetOtpSent => _isResetOtpSent;
  bool _isResetOtpSent = false;

  bool get showCurrentPassword => _showCurrentPassword;
  bool _showCurrentPassword = false;

  bool get showNewPassword => _showNewPassword;
  bool _showNewPassword = false;

  bool get showConfirmPassword => _showConfirmPassword;
  bool _showConfirmPassword = false;

  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
  }

  MerchantInfoModel get merchantInfo => _merchantInfo;
  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  bool get showPassword => _showPassword;

  void setMerchantDbaName(String name) {
    _merchantDbaName = name;
    notifyListeners();
  }

  /// Clears OTP state and controllers
  void clearOtp() {
    _isOtpSent = false;
    _phoneNumberOtpController.clear();
    _emailOtpController.clear();
    notifyListeners();
  }

  /// Resets all login state and controllers

  void resetAllAndCheckRememberMe({bool fromDispose = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isLoggedIn = false;
      _isLoading = false;
      _isOtpSent = false;
      _showPassword = false;
      _showEmailOtp = false;

      _merchantIdController.clear();
      _passwordController.clear();
      _phoneNumberOtpController.clear();
      _emailOtpController.clear();

      if (!fromDispose) notifyListeners();

      // Run rememberMe logic safely AFTER reset
      SharedPreferences pref = await SharedPreferences.getInstance();
      bool? rememberMe = pref.getBool('rememberMe');
      if (rememberMe == null) {
        setRememberMe(false);
        return;
      }
      setRememberMe(rememberMe);
      if (rememberMe) {
        merchantIdController.text = pref.getString('userName') ?? '';
        passwordController.text = pref.getString('password') ?? '';
      }
    });
  }

  /// Toggle password field visibility (TODO: Consider ValueNotifier for efficiency)
  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleResetPasswordVisibility(
      {bool isCurrentPassword = false,
      bool isNewPassword = false,
      bool isConfirmPassword = false}) {
    if (isCurrentPassword) {
      _showCurrentPassword = !_showCurrentPassword;
    } else if (isNewPassword) {
      _showNewPassword = !_showNewPassword;
    } else if (isConfirmPassword) {
      _showConfirmPassword = !_showConfirmPassword;
    }

    notifyListeners();
  }

  /// Toggle email OTP field visibility (TODO: Consider ValueNotifier for efficiency)
  void toggleEmailOtpVisibility() {
    _showEmailOtp = !_showEmailOtp;
    notifyListeners();
  }

  /// Handles the login/OTP button press logic
  void onPresSendButton(GlobalKey<FormState> formKeys) async {
    if (formKeys.currentState?.validate() ?? false) {
      _setLoading(true);
      if (!_isOtpSent) {
        await sendMerchantLoginOtp();
      } else {
        await validateMerchantLoginOtp();
      }
    } else {
      alertService.error('Please fill in all required fields.');
    }
  }

  // void showMerchantIdsPopup(
  //     BuildContext context, Map<String, dynamic> merchantIds) {
  //   // Filter out null values if needed
  //   final validEntries =
  //       merchantIds.entries.where((entry) => entry.value != null).toList();

  //   if (kDebugMode) {
  //     print('Valid Merchant IDs: $validEntries');
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setStateMethod) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           content: SizedBox(
  //             width: double.maxFinite,
  //             child: validEntries.isNotEmpty
  //                 ? ListView.builder(
  //                     shrinkWrap: true,
  //                     itemCount: validEntries.length,
  //                     itemBuilder: (context, index) {
  //                       final entry = validEntries[index];
  //                       return Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Expanded(
  //                             child: ListTile(
  //                               title: Text(entry.value.toString()),
  //                               subtitle: Text(entry.key),
  //                               contentPadding: EdgeInsets.zero,
  //                             ),
  //                           ),
  //                           IconButton(
  //                             icon: Icon(
  //                                 _selectedMerchantId != null
  //                                     ? _selectedMerchantId.key != entry.key
  //                                         ? Icons.circle_outlined
  //                                         : Icons.circle
  //                                     : Icons.circle_outlined,
  //                                 size: 20),
  //                             onPressed: () {
  //                               _selectedMerchantId = entry;
  //                               setStateMethod(() {});
  //                             },
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   )
  //                 : const Text('No valid merchant IDs found.'),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () async {
  //                 final secureStorage = BoxStorage();
  //                 await secureStorage.saveUserDetails(loginResponse,
  //                     userName: _merchantIdController.text);
  //                 await MerchantServices().logOutFromUserAlreadyLogin(
  //                     userName: _merchantIdController.text);

  //                 Navigator.pop(context);

  //                 Future.delayed(const Duration(milliseconds: 1000), () {
  //                   Logout().clearSharedPref();
  //                   Hive.box(Constants.hiveName).clear();
  //                 });
  //                 // ignore: use_build_context_synchronously
  //               },
  //               child: const Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               style: ButtonStyle(
  //                 backgroundColor:
  //                     WidgetStateProperty.all(AppColors.kPrimaryColor),
  //               ),
  //               onPressed: () {
  //                 if (_selectedMerchantId == null) {
  //                   alertService
  //                       .error('Please select a Merchant ID to proceed.');
  //                   return;
  //                 }

  //                 loginResponse['acqMerchantId'] = _selectedMerchantId.key;
  //                 loginResponse['shopName'] = _selectedMerchantId.value;

  //                 _handleLoginSuccess();
  //                 Navigator.pop(context);
  //               },
  //               child: const Text(
  //                 'Proceed',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  /// Helper for post-login success actions
  Future<void> _handleLoginSuccess() async {
    await StorageServices.saveSecureStorage(
      loginResponse,
      userName: _merchantIdController.text,
      password: _passwordController.text,
    );
    loginResponse = null;
    // TokenManager().start(NavigationService.navigatorKey.currentState!.context);
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      'merchantHomeScreen',
      (route) => false,
    );
  }

  bool isNullOrEmpty(dynamic value) {
    if (value == null) return true; // missing key or null
    final str = value.toString().trim();
    return str.isEmpty || str.toLowerCase() == "null";
  }

  /// Sends merchant login OTP
  Future<void> sendMerchantLoginOtp() async {
    req
      ..deviceType = "MOBILE"
      ..merchantId = _merchantIdController.text
      ..password = _passwordController.text;

    try {
      final res =
          await _merchantServices.merchantSelfLogin(req.sentOtpToJson());
      loginResponse = res.data;

      if (loginResponse != null &&
          loginResponse['responseCode'] == "00" &&
          res.statusCode == 200) {
        if (loginResponse['twoFARequired'] == true) {
          _isOtpSent = true;
          alertService.success(
              loginResponse['responseMessage'] ?? 'OTP sent successfully');
        } else {
          /// If two-factor authentication is not required, proceed to login
          /// Code done by Anas
          if (isNullOrEmpty(loginResponse['merchantId']) ||
              isNullOrEmpty(loginResponse['acqMerchantId'])) {
            alertService.error('Invalid Merchant ID');
            return;
          }

          // final merchantIds = loginResponse['merchantIds'];
          // _selectedMerchantId = null;

          // if (merchantIds != null &&
          //     ((merchantIds is Map && merchantIds.isNotEmpty) ||
          //         (merchantIds is List && merchantIds.isNotEmpty))) {
          //   showMerchantIdsPopup(
          //       // ignore: use_build_context_synchronously
          //       NavigationService.navigatorKey.currentState!.context,
          //       merchantIds);
          //   return;
          // }
          _isLoggedIn = true;
          _isOtpSent = false;
          await _handleLoginSuccess();

          // alertService
          //     .error(loginResponse['responseMessage'] ?? 'Failed to Send OTP');
        }
      } else {
        if (loginResponse['responseCode'] == "04") {
          NavigationService.navigatorKey.currentState?.pushNamed(
              'resetPassword',
              arguments: _merchantIdController.text);
          return;
        }

        _isOtpSent = false;
        alertService
            .error(loginResponse['responseMessage'] ?? 'Failed to Send OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      alertService
          .error('An error occurred while sending OTP: \\${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Validates merchant login OTP
  Future<void> validateMerchantLoginOtp(
      {bool fromResetPassword = false, String? userName}) async {
    req
      ..merchantId = !fromResetPassword ? _merchantIdController.text : userName
      ..emailOtp = _emailOtpController.text;

    // Debug bypass for OTP (should be removed or guarded in production)
    // if (kDebugMode) {
    //   await _handleLoginSuccess();
    //   alertService.success('Bypass opt');
    //   return;
    // }
    try {
      final res =
          await _merchantServices.verifyOtp(req.validateEmailOtpToJson());
      final response = res.data;

      if (res.statusCode == 200 && response?['errorMessage'] == "Success") {
        /// If OTP verification is successful, proceed to login - From Login Screen
        if (!fromResetPassword) {
          _isLoggedIn = true;
          _isOtpSent = false;
          await _handleLoginSuccess();
        } else {
          _isResetOtpSent = false;
        }

        alertService.success(
            response['successMessage'] ?? 'OTP Verified successfully!');
      } else {
        alertService
            .error(response?['errorMessage'] ?? 'OTP verification failed');
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      alertService
          .error('An error occurred while verifying OTP: \\${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Sends a forgot password request to the server
  ///
  /// This will send a forgot password request to the server, which will
  /// send a reset password link to the registered email address.
  ///
  /// If the request is successful, a success message will be displayed
  /// to the user.
  ///
  /// If the request fails, an error message will be displayed to the user.
  Future<void> forgotPassword() async {
    try {
      final res =
          await _merchantServices.forgotPassword(_merchantIdController.text);
      final response = res.data;

      if (res.statusCode == 200 && response['responseCode'] == "00") {
        alertService.success(response['responseMessage'] ??
            'Forgot Password Link Successfully sent');
      } else {
        alertService.error(response['responseMessage'] ??
            'Failed to send Forgot Password Link');
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      alertService.error(
          'An error occurred while processing Forgot Password: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setRememberMe(bool value) async {
    _isRemember = value;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('rememberMe', value);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future resetPassword(String userName, String currentPasswordValue,
      String newPasswordValue, String confirmPasswordValue) async {
    try {
      req
        ..merchantId = userName
        ..currentPassword = currentPasswordValue
        ..password = newPasswordValue
        ..confirmPassword = confirmPasswordValue;

      final res =
          await _merchantServices.restPassword(req.resetPasswordToJson());

      dynamic response = res.data;

      response = response.isEmpty ? null : response;

      if (res.statusCode == 200 && response?['responseMessage'] != null) {
        alertService.success(
            response?['responseMessage'] ?? 'Password reset successful');

        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'login',
          (route) => false,
        );
      } else {
        alertService
            .error(response?['responseMessage'] ?? 'Failed to reset password');
      }
    } catch (e) {
      alertService.error('An error occurred while resetting password');
    }
  }

  void showResetOtp() {
    _isResetOtpSent = true;
    notifyListeners();
  }

  void setMerchantIds(List<dynamic> merchantIdList) {
    _merchantIds = merchantIdList;
    print(_merchantIds);
    notifyListeners();
  }
}
// All optimizations applied: state management, code duplication, error handling, and code clarity improved.
