/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : USER_SERVICE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anet_merchant_app/config/constants.dart';
import 'package:anet_merchant_app/storage/secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../config/endpoints.dart';
import '../config/static_functions.dart';
import '../main.dart';
import 'connection.dart';

class UserServices {
  late String token;
  dynamic user;

  /*
  * SERVICE NAME: loginService
  * DESC: User to Login into Sifr Application
  * METHOD: POST
  * Params: LoginRequestModel
  */
  // loginService(requestModel) async {
  //   Connection connection = Connection();
  //   var url = EndPoints.baseApi9502 + EndPoints.loginAPI;
  //   var response = await connection.postWithOutToken(url, requestModel);
  //   return response;
  // }

  salesTeamLogin(requestModel) async {
    Connection connection = Connection();

    // var url = "${EndPoints.baseApiPublic}/NanoPay/v1/login";

    var url = "${EndPoints.baseApiPublicNanoUMS}login";

    // print(url);
    // var url = EndPoints.baseApi9502 + EndPoints.loginAPI;

    var response = await connection.postWithOutToken(url, requestModel);

    return response;
  }

  /*
  * SERVICE NAME: userCheck
  * DESC:Check whether the user Exist or Not
  * METHOD: GET
  * Params: userName
  */
  // userCheck(String userName) async {
  //   Connection connection = Connection();
  //   var url = EndPoints.baseApi9502 + EndPoints.userCheckAPI + userName;
  //   var response = await connection.getWithOutToken(url);
  //   return response;
  // }

  // sendForgotPasswordLink(String userName) async {
  //   Connection connection = Connection();
  //   // var url = EndPoints.baseApi9502 + EndPoints.userCheckAPI + userName;
  //   var url = "${EndPoints.baseApiPublic}/NanoPay/v1/forgotPassword/$userName";
  //   var response = await connection.getWithOutToken(url);
  //   return response;
  // }

  accountValidation(
    String accno,
    String ifsc,
  ) async {
    String token = boxStorage.getToken();

// Ensure token is not null or empty

    var newheader = {
      'Authorization': 'Bearer $token',
      'accessToken': "z5yYAdcG4lJMAA7oeMoh69teKqJUxW8K",
      'Content-Type': 'application/json',
    };

    if (kDebugMode) print("newheader$newheader");

    var verifyAccountUel = Uri.parse(
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/validateBankAccountVerifications");

    if (kDebugMode) {
      print(
          "verifyAccountUel${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/validateBankAccountVerifications");
    }

    // final newreqbody = {
    //   "task": "bankTransferLite",
    //   "userId": "userId",
    //   "essentials": {"beneficiaryAccount": accno, "beneficiaryIFSC": ifsc}
    // };
    final reqbody = {"beneficiaryAccount": accno, "beneficiaryIFSC": ifsc};
    if (kDebugMode) print("newreqbody$reqbody");

    var responseapi = await http.post(verifyAccountUel,
        headers: newheader, body: jsonEncode(reqbody));

    if (kDebugMode) print("$verifyAccountUel");
    if (kDebugMode) print(responseapi.body);

    //if(kDebugMode)print(newheader);
    //if(kDebugMode)print(userId);
    //if(kDebugMode)print("second api reponseStatus code ${responseapi.statusCode}");
    //if(kDebugMode)print(responseapi.body);
    //if(kDebugMode)print(responseapi.statusCode);
    return responseapi;
  }

  Future getBankNameFromIfsc(String ifsc) async {
    String token = boxStorage.getToken();

// Ensure token is not null or empty
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // final headers = {'Authorization': 'Bearer $token'};
    var getBankNameApi = Uri.parse(
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getBankNameByIFSC/$ifsc");

    var response = await http.get(
      getBankNameApi,
      headers: headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    }
  }

  gstValidation(
    String gstNo,
  ) async {
    String token = boxStorage.getToken();

    var newheader = {
      'Authorization': 'Bearer $token',
      'accessToken': "z5yYAdcG4lJMAA7oeMoh69teKqJUxW8K",
      'Content-Type': 'application/json',
    };
    var gstVerify = Uri.parse(
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/searchGSTNS");
    final reqbody = {
      "gstin": gstNo,
      "returnFilingFrequency": true,
      "filingDataForYears": "0"
    };

    var responseapi = await http.post(gstVerify,
        headers: newheader, body: jsonEncode(reqbody));
    //if(kDebugMode)print(newheader);

    //if(kDebugMode)print("second api reponseStatus code ${responseapi.statusCode}");
    if (kDebugMode) print(responseapi.body);
    return responseapi.body;
  }

  panValidation(String panNumber, bool isConfirm) async {
    try {
      String token = boxStorage.getToken();

      var newheader = {
        'Authorization': 'Bearer $token',
        'accessToken': "z5yYAdcG4lJMAA7oeMoh69teKqJUxW8K",
        'Content-Type': 'application/json',
      };

      var validatePanAadhar = Uri.parse(
          "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/validatePanAadhar");

      final panVerifyReq = {
        "number": panNumber,
        "returnIndividualTaxComplianceInfo": "true",
        "consent": "Y"
      };

      var response = await http.post(validatePanAadhar,
          headers: newheader, body: jsonEncode(panVerifyReq));

      return response;
    } catch (e) {
      return "ERROR";
    }
  }

  sendAddhaarVerificationemail(String emailId) async {
    String token = boxStorage.getToken();

    var newheader = {
      'Authorization': 'Bearer $token',
      'accessToken': "z5yYAdcG4lJMAA7oeMoh69teKqJUxW8K",
      'Content-Type': 'application/json',
    };

    if (kDebugMode) print("newheader$newheader");

    var sendAadharLink = Uri.parse(
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/createToSendAadharDigiLink");
    final reqbody = {
      "emailId": emailId,
      "signup": true,
      "redirectUrl": "https://www.signzy.com/",
      "redirectTime": "1",
      "callbackUrl": "https://signtest123.requestcatcher.com/",
      "successRedirectUrl": "https://www.signzy.com/",
      "successRedirectTime": "5",
      "failureRedirectUrl": "https://www.signzy.com/",
      "failureRedirectTime": "5",
      "logoVisible": "true",
      "logo":
          "https://rise.barclays/content/dam/thinkrise-com/images/rise-stories/Signzy-16_9.full.high_quality.jpg",
      "supportEmailVisible": "true",
      "supportEmail": "support@signzy.com",
      "purpose": "kyc",
      "getScope": true,
      "consentValidTill": 1829141682,
      "showLoaderState": true,
      "internalId": "<Internal ID>",
      "companyName": "Signzy",
      "favIcon":
          "https://rise.barclays/content/dam/thinkrise-com/images/rise-stories/Signzy-16_9.full.high_quality.jpg"
    };
    var response = await http.post(sendAadharLink,
        headers: newheader, body: jsonEncode(reqbody));

    return response;
  }

  checkAadharVerificationStatus(String aadharVerificationrequestId) async {
    String token = boxStorage.getToken();

    var newheader = {
      'Authorization': 'Bearer $token',
      'accessToken': "z5yYAdcG4lJMAA7oeMoh69teKqJUxW8K",
      'Content-Type': 'application/json',
    };

    if (kDebugMode) print("newheader$newheader");

    var sendAadharLink = Uri.parse(
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getEAadhaar");
    final reqbody = {
      "requestId": aadharVerificationrequestId,
      "extraDigitalCertificateParams": true
    };

    var response = await http.post(sendAadharLink,
        headers: newheader, body: jsonEncode(reqbody));
    return response;
  }

  sendEmailOtp({required String emailId}) async {
    Connection connection = Connection();
    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/sendOtpToEmail/$emailId";

    var response = await connection.get(url);
    return response;
  }

  verifyEmailOtp({
    required String emailId,
    required String otp,
  }) async {
    Connection connection = Connection();
    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/verifyEmailOtp";
    var response = await connection.post(url, {"email": emailId, "otp": otp});

    return response;
  }

  // updateMerchantStatus(req) async {
  //   Connection connection = Connection();
  //   var url = EndPoints.baseApi9503 + EndPoints.updateMerchantStatus;
  //   var response = await connection.post(url, req);
  //   return response;
  // }

  /*
  * SERVICE NAME: emailMobileCheck
  * DESC:Email Id/Mobile No Exist or Not
  * METHOD: POST
  * Params: Type and request
  */
  // emailMobileCheck(String type, String request) async {
  //   var instId = Constants.instId;
  //   var requests = '?instId=$instId&$type=$request';
  //   Connection connection = Connection();
  //   var url = EndPoints.baseApi9502 + EndPoints.emailCheck + requests;
  //   var response = await connection.getWithOutToken(url);
  //   return response;
  // }

  Future<dynamic> getMdrSummary(
      String mdrType, String turnOver, int mccTypeCode) async {
    Connection connection = Connection();

    final requestBody = {
      "mdrType": mdrType,
      "mccTypeCode": mccTypeCode,
      "turnOverType": turnOver
    };

    if (kDebugMode) print(requestBody);

    // var url = 'http://10.0.38.83:9508/NanoPay/Middleware/UiApi/mdrDetails';
    var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/mdrDetails';
    var response = await connection.post(url, requestBody);
    return response;
  }

  Future<dynamic> checkForExistingMerchant(String number,
      {bool fromMyApplicationsScreen = false}) async {
    Connection connection = Connection();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userName = prefs.getString('userName');

    var object = {"mobileNo": number};

    if (fromMyApplicationsScreen) {
      object['userId'] = userName!;
    }

    // var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getMerchantOnboardingInfo/$number';
    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/MerchantOnboardList';

    var response = await connection.post(url, object, timeOutSeconds: 60);
    return response;
  }

  Future<dynamic> sendOtpFunction(String number,
      {bool? partiallyOnboarded}) async {
    Connection connection = Connection();

    var object = {
      "mobileNumber": number,
      "partiallyOnboarded": partiallyOnboarded ?? false
    };

    // var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getMerchantOnboardingInfo/$number';
    var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/INDOtp/generate';

    var response = await connection.post(url, object, timeOutSeconds: 60);
    return response;
  }

  Future<dynamic> validateOtpFunction(otpResponse, otp) async {
    Connection connection = Connection();

    var object = {
      "mobileNumber": otpResponse['data']?.isNotEmpty == true
          ? otpResponse['data'][0]['mobileNumber']
          : null,
      "secretKey": otpResponse['data']?.isNotEmpty == true
          ? otpResponse['data'][0]['secretKey']
          : null,
      "otp": encryptMethod(otp)
    };

    // var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getMerchantOnboardingInfo/$number';
    var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/INDOtp/validate';

    var response = await connection.post(url, object, timeOutSeconds: 60);

    return response;
  }

  Future sendTermsAndConditions(
      String? mailId, String requestType, String legalName,
      {dynamic mdrSummaryList, responseMerchantId}) async {
    Connection connection = Connection();

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    // String? userName = prefs.getString('userName');

    final Map<String, dynamic> requestBody = {
      "userName": legalName,
      "email": mailId,
      "requestType": requestType
    };

    if (requestType == "SERVICE_AGREEMENT") {
      requestBody['mdrReqDetails'] = mdrSummaryList;
      requestBody['merchantId'] = responseMerchantId;
    }
    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/sendTermsAndConditions';
    var response = await connection.post(
      url,
      requestBody,
      timeOutSeconds: 20,
    );

    if (kDebugMode) print("Response ${response.body}");
    return response;
  }

  Future getTcAndAgreementStatus(String? mailId) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getTcAndAgreementStatus/$mailId';
    var response = await connection.get(
      url,
    );
    if (kDebugMode) print("Response ${response.body}");
    return response;
  }

  static const String prefKeyOnboardingValues = 'merchantOnboardingValues';
  static const String prefKeyOFtime = 'OnboardingValuesRefreshedtime';
  getMerchantOnboardingValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if cached data exists
    String? cachedData = prefs.getString(prefKeyOnboardingValues);
    int? cachedTime = prefs.getInt(prefKeyOFtime);

    if (cachedData != null && cachedTime != null) {
      DateTime lastFetchTime = DateTime.fromMillisecondsSinceEpoch(cachedTime);
      DateTime now = DateTime.now();

      // If cached data is less than 1 hour old, return it
      if (now.difference(lastFetchTime).inMinutes < 60) {
        return http.Response(cachedData, 200); // Return as an HTTP response
      }
    }

    // Fetch new data from API
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/GetMerchantOnboardingValues';

    var response = await connection.get(url);

    if (response.statusCode == 200) {
      // Save new response and timestamp
      await prefs.setString(prefKeyOnboardingValues, response.body);
      await prefs.setInt(prefKeyOFtime, DateTime.now().millisecondsSinceEpoch);
    }

    return response;
  }

  Future<dynamic> getDocumentsFromApi(merchantId) async {
    Connection connection = Connection();

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/kycDocument/$merchantId';

    if (kDebugMode) {
      print("url$url");
    }

    var response = await connection.get(url);
    if (kDebugMode) {
      print("Defaultvalues Api response code${response.statusCode}");
    }
    return response;
  }

  Future<dynamic> getMerchantApplication(
      requestBody, page, resultPerPage) async {
    try {
      Connection connection = Connection();

      var url =
          '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/MerchantMobileAppOnboardList?page=$page&size=$resultPerPage';

      var response =
          await connection.post(url, requestBody, timeOutSeconds: 60);

      if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 1));
        return getMerchantApplication(requestBody, page, resultPerPage);
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<dynamic> getMerchantMobileAppDashBoardData(userName) async {
    Connection connection = Connection();

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getMerchantMobileAppDashBoardData/$userName';

    var response = await connection.get(url);
    if (kDebugMode) {
      print(
          "getMerchantMobileAppDashBoardData Api response code${response.statusCode}");
    }
    return response;
  }

  Future<dynamic> getMerchantFromAcquirerDefinitionForGettingGuid(
      merchantID) async {
    try {
      var requestBody = {"merchantId": merchantID};

      Connection connection = Connection();

      var url =
          "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/GetAllMerchantsPagination";

      var response =
          await connection.post(url, requestBody, timeOutSeconds: 60);

      if (kDebugMode) {
        print("Defaultvalues Api response code${response.statusCode}");
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<dynamic> getTerminalsByGuid(guid) async {
    Connection connection = Connection();

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/GetTerminalByMerchantId/$guid';

    if (kDebugMode) {
      print(url);
    }

    var response = await connection.get(url);
    if (kDebugMode) {}
    return response;
  }

  Future<dynamic> getMerchantApplicationStatus(merchantInd) async {
    Connection connection = Connection();
    final requestBody = {"merchantId": "$merchantInd"};

    if (kDebugMode) print("requestBody$requestBody");

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/merchantOnboardingStatus';

    if (kDebugMode) print("url$url");

    var response = await connection.post(url, requestBody, timeOutSeconds: 20);

    return response;
  }

  Future<dynamic> postMerchantOnBoarding(merchantInd) async {
    Connection connection = Connection();

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/onboardByHitachiOrAuBank/$merchantInd';
    var response = await connection.get(url);

    return response;
  }

  Future<dynamic> postPaymentMethod(requestBody) async {
    Connection connection = Connection();

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/update/paymentStatus';
    var response = await connection.post(url, requestBody);

    return response;
  }

  getAcqApplicationid(String guid) async {
    Connection connection = Connection();
    var url =
        'http://omasoftposqc.omaemirates.com:9508/NanoPay/Middleware/UiApi/GetAllAcquirerData/$guid';
    var resonr = await connection.get(url);

    if (kDebugMode) print('---------Get application id---------------');
    if (kDebugMode) print(resonr.body);

    //if(kDebugMode)print(prefs.getString('bearerToken') ?? 'error in reciving token');
    final Map<String, dynamic> data = json.decode(resonr.body);
    List<dynamic> acqApplications = data['data'];

    return acqApplications;
  }

  int generateRandom13DigitNumber() {
    Random random = Random();

    // Generate three random integers to form a 13-digit number
    int prefix = random.nextInt(900) +
        100; // Random number between 100 and 999 (3 digits)
    int suffix1 =
        random.nextInt(1000); // Random number between 0 and 999 (3 digits)
    int suffix2 =
        random.nextInt(10000); // Random number between 0 and 9999 (4 digits)

    // Combine the three parts to form a 13-digit number
    int random13DigitNumber = prefix * 10000000000 + suffix1 * 10000 + suffix2;

    return random13DigitNumber;
  }

  Future updateTerminalStatus(String? terminalId) async {
    Connection connection = Connection();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userName = prefs.getString('userName');

    var url =
        '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/updateDeploymentStatus';

    var object = {
      "terminalId": terminalId,
      "instId": "",
      "userName": userName,
      "mkCk": ""
    };

    if (kDebugMode) print(jsonEncode(object));
    if (kDebugMode) print(url);
    // return;

    var response = await connection.post(url, object, timeOutSeconds: 20);

    if (kDebugMode) {
      print(response.body);
    }

    return response;
  }

  Future logOut(String? userName) async {
    Connection connection = Connection();

    var object = {"userName": userName};

    // var url = '${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getMerchantOnboardingInfo/$number';
    var url = '${EndPoints.baseApiPublicNanoUMS}logout';

    if (kDebugMode) print('url$url');

    var response = await connection.post(url, object, timeOutSeconds: 25);

    if (kDebugMode) print('logOutResponse${response.body}');

    return response;
  }

  BoxStorage boxStorage = BoxStorage();
  Future refreshToken() async {
    Connection connection = Connection();
    String token = boxStorage.getToken();
    var url = '${EndPoints.baseApiPublicNanoUMS}refreshToken/$token';

    var response = await connection.get(url, fromRefreshTokenAPI: true);

    if (kDebugMode) print('url ${response.body}');

    var decodedData = jsonDecode(response.body);

    if (response.statusCode == 401) {
      NavigationService.navigatorKey.currentState
          ?.pushReplacementNamed('login');
      alertService.errorToast(Constants.unauthorized);
      clearStorage();
      return;
    }

    BoxStorage secureStorage = BoxStorage();
    await secureStorage.saveUserDetails(decodedData);

    if (response.statusCode == 200) {
      return decodedData;
    }
  }

  encryptMethod(data) {
    final key = encrypt.Key.fromUtf8('kycDocsEncrypKey');

    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, padding: 'PKCS7', mode: encrypt.AESMode.ecb));

    final encrypted = encrypter.encrypt(data, iv: iv);

    final encryptedBytes = encrypted.base64.toString();

    return encryptedBytes;
  }

  /*
  * SERVICE NAME: fetchTermsAndCondition
  * DESC:Fetch Terms and Condition to Accept While Registering
  * METHOD: GET
  * Params: type
  */
}
