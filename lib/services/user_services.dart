/* ===============================================================
| Project : SIFR
| Page    : USER_SERVICE.DART
| Date    : 23-MAR-2023
|
*  ===============================================================*/

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/models/models.dart';
import 'package:sifr_latest/storage/secure_storage.dart';

import '../config/endpoints.dart';
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
  loginService(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.loginAPI;
    var response = await connection.postWithOutToken(url, requestModel);
    return response;
  }

  salesTeamlogin(requestModel) async {
    Connection connection = Connection();
    var url = "http://172.29.100.221:9508/NanoPay/v1/login";
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
  userCheck(String userName) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.userCheckAPI + userName;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  sendForgotPasswordLink(String userName) async {
    Connection connection = Connection();
    // var url = EndPoints.baseApi9502 + EndPoints.userCheckAPI + userName;
    var url = "http://172.29.100.221:9508/NanoPay/v1/forgotPassword/$userName";
    var response = await connection.getWithOutToken(url);
    return response;
  }

  accountValidation(
    String accno,
    String ifsc,
    String name,
    String phonenumber,
  ) async {
    String token = boxStorage.getToken();

// Ensure token is not null or empty
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // final headers = {'Authorization': 'Bearer $token'};
    var urlnew = Uri.parse(
        'http://172.29.100.221:9508/NanoPay/Middleware/UiApi/addOrUpdateLogin');
    var body = jsonEncode(
        {"username": "omaEmirates_preprod_v2", "password": "doXpr3KeKT"});

    var response = await http.post(urlnew, headers: headers, body: body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String id = jsonResponse['id'];
      String userId = jsonResponse['userId'];

      print("id from response  $id");
      print("userId from response $userId");
      var newheader = {
        'Authorization': 'Bearer $token',
        'accessToken': id,
        'Content-Type': 'application/json',
      };

      var verifyAccountUel = Uri.parse(
          "http://172.29.100.221:9508/NanoPay/Middleware/UiApi/validateBankAccountVerifications");

      final newreqbody = {
        "task": "bankTransferLite",
        "userId": userId,
        "essentials": {
          "beneficiaryMobile": phonenumber,
          "beneficiaryAccount": accno,
          "beneficiaryName": name,
          "beneficiaryIFSC": ifsc
        }
      };

      var responseapi = await http.post(verifyAccountUel,
          headers: newheader, body: jsonEncode(newreqbody));
      // print(newheader);
      // print(userId);
      // print("second api reponseStatus code ${responseapi.statusCode}");
      // print(responseapi.body);
      return responseapi.body;
    }

    return false;
  }

  gstValidation(
    String gstNo,
  ) async {
    String token = boxStorage.getToken();

// Ensure token is not null or empty
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // final headers = {'Authorization': 'Bearer $token'};
    var urlnew = Uri.parse(
        'http://172.29.100.221:9508/NanoPay/Middleware/UiApi/addOrUpdateLogin');
    var body = jsonEncode(
        {"username": "omaEmirates_preprod_v2", "password": "doXpr3KeKT"});

    var response = await http.post(urlnew, headers: headers, body: body);
    print("Fist Api responsecode ${response.statusCode}");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String id = jsonResponse['id'];
      String userId = jsonResponse['userId'];

      print("id from response  $id");
      print("userId from response $userId");
      var newheader = {
        'Authorization': 'Bearer $token',
        'accessToken': id,
        'Content-Type': 'application/json',
      };

      var gstVerify = Uri.parse(
          "http://172.29.100.221:9508/NanoPay/Middleware/UiApi/addOrUpdateGstns");

      final newreqbody = {
        "task": "gstinSearch",
        "userId": userId,
        "essentials": {"gstin": gstNo}
      };

      var responseapi = await http.post(gstVerify,
          headers: newheader, body: jsonEncode(newreqbody));
      // print(newheader);
      // print(userId);
      // print("second api reponseStatus code ${responseapi.statusCode}");
      // print(responseapi.body);
      return responseapi.body;
    }

    return false;
  }

  panValidation(
    String panNumber,
  ) async {
    String token = boxStorage.getToken();

// Ensure token is not null or empty
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // final headers = {'Authorization': 'Bearer $token'};
    var urlnew = Uri.parse(
        'http://172.29.100.221:9508/NanoPay/Middleware/UiApi/addOrUpdateLogin');
    var body = jsonEncode(
        {"username": "omaEmirates_preprod_v2", "password": "doXpr3KeKT"});

    var response = await http.post(urlnew, headers: headers, body: body);
    print("Fist Api responsecode ${response.statusCode}");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String id = jsonResponse['id'];
      String userId = jsonResponse['userId'];

      print("id from response  $id");
      print("userId from response $userId");
      var newheader = {
        'Authorization': 'Bearer $token',
        'accessToken': id,
        'Content-Type': 'application/json',
      };

      var gstVerify = Uri.parse(
          "http://172.29.100.221:9508/NanoPay/Middleware/UiApi/validatePanAadhar");

      final newreqbody = {
        "requestType": "PAN",
        "panNumber": panNumber,
        "userId": "65a4f0adcd1c770023dd5ace"
      };

      var responseapi = await http.post(gstVerify,
          headers: newheader, body: jsonEncode(newreqbody));
      // print(newheader);
      // print(userId);
      print("second api reponseStatus code ${responseapi.statusCode}");
      print(responseapi.body);
      return responseapi.body;
    }

    return false;
  }

  sendAddhaarOtp(String addhaarNumber) async {
    String token = boxStorage.getToken();

// Ensure token is not null or empty

    // final headers = {'Authorization': 'Bearer $token'};

    var newheader = {
      'Authorization': 'Bearer $token',
      'accessToken': "C4kYXdmCpS4ojpdAXnuftstjpyAKsd0x",
      'Content-Type': 'application/json',
    };

    var addhaarverify = Uri.parse(
        "http://172.29.100.221:9508/NanoPay/Middleware/UiApi/validatePanAadhar");

    final newreqbody = {"requestType": "AADHAR", "aadharNumber": addhaarNumber};

    var responseapi = await http.post(addhaarverify,
        headers: newheader, body: jsonEncode(newreqbody));
    // print(newheader);
    // print(userId);
    print("second api reponseStatus code ${responseapi.statusCode}");
    print(responseapi.body);
    return responseapi.body;
  }

  validateAddhaarOtp(String addhaarNumber, String addhaarOtp) async {
    String token = boxStorage.getToken();

    var newheader = {
      'Authorization': 'Bearer $token',
      'accessToken': "C4kYXdmCpS4ojpdAXnuftstjpyAKsd0x",
      'Content-Type': 'application/json',
    };

    var addhaarverify = Uri.parse(
        "http://172.29.100.221:9508/NanoPay/Middleware/UiApi/validatePanAadhar");

    final newreqbody = {
      "requestType": "VERIFYAADHAROTP",
      "requestId": "aadhaar_v2_uBztmfFDSUsJWtDnYxwO",
      "otp": addhaarOtp,
      "aadharNumber": addhaarNumber
    };

    var responseapi = await http.post(addhaarverify,
        headers: newheader, body: jsonEncode(newreqbody));
    // print(newheader);
    // print(userId);
    print("second api reponseStatus code ${responseapi.statusCode}");
    print(responseapi.body);
    return responseapi.body;
  }

  /*
  * SERVICE NAME: updateMerchantStatus
  * DESC:Update Merchant Status Active/InActive
  * METHOD: POST
  * Params: Merchant Id And Status
  * to pass token in Headers
  */
  updateMerchantStatus(req) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9503 + EndPoints.updateMerchantStatus;
    var response = await connection.post(url, req);
    return response;
  }

/*
  * SERVICE NAME: emailMobileCheck
  * DESC:Email Id/Mobile No Exist or Not
  * METHOD: POST
  * Params: Type and request
  */
  emailMobileCheck(String type, String request) async {
    var instId = Constants.instId;
    var requests = '?instId=$instId&$type=$request';
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.emailCheck + requests;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: otpVerification
  * DESC:OTP Verification for Password/Pin Reset
  * METHOD: POST
  * Params: loginRequestModel and Url
  */
  otpVerification(String userName) async {
    Connection connection = Connection();
    LoginRequestModel loginRequestModel = LoginRequestModel();
    var url = EndPoints.baseApi9502 + EndPoints.mobileOtpAPI;
    loginRequestModel.userName = userName;
    loginRequestModel.instId = Constants.instId;
    var response = await connection.postWithOutToken(url, loginRequestModel);
    return response;
  }

  /*
  * SERVICE NAME: otpValidate
  * DESC:OTP Validate for Password/Pin Reset
  * METHOD: POST
  * Params: OtpValidateRequest and Url
  */
  otpValidate(otpValidateRequest) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.mobileOtpValidateAPI;
    var response = await connection.postWithOutToken(url, otpValidateRequest);
    return response;
  }

  /*
  * SERVICE NAME: deviceRegister
  * DESC:Register Device While Login
  * METHOD: POST
  * Params: instId,userName and deviceId
  */
  deviceRegister(params) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.deviceRegister;
    var response = await connection.postWithOutToken(url, params);
    return response;
  }

  /*
  * SERVICE NAME: resetPassword
  * DESC:Reset Passcode or Pin
  * METHOD: POST
  * Params: ResetPasscode
  */
  resetPassword(ResetPasscode resetPasscode) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.resetPasscodeAPI;
    var response = await connection.postWithOutToken(url, resetPasscode);
    return response;
  }

  /*
  * SERVICE NAME: securityQuestion
  * DESC:Fetch Security Question for Reset Password/Pin
  * METHOD: POST
  * Params: userName
  */
  securityQuestion(String userName) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi9502}${EndPoints.securityQuestionAPI}${Constants.instId}/$userName';
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: securityVerification
  * DESC:Verify Security Question and Answers for Reset Password/Pin
  * METHOD: POST
  * Params: SecurityQuestionVerification
  */
  securityVerification(SecurityQuestionVerification requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.securityQuestionVerificationAPI;
    var response = await connection.postWithOutToken(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: forgetUserName
  * DESC:Recover Username
  * METHOD: GET
  * Params: email
  */
  forgetUserName(String email) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi9502}${EndPoints.forgetUserNameAPI}${Constants.instId}/$email';
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: fetchFaq
  * DESC:Fetch Frequently Asked Questions
  * METHOD: GET
  * Params: NA
  */
  fetchFaq() async {
    Connection connection = Connection();
    var url = EndPoints.getFaq;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: fetchSecurity
  * DESC:Fetch Security Questions While Registering
  * METHOD: GET
  * Params: NA
  */
  fetchSecurity() async {
    Connection connection = Connection();
    var url = EndPoints.getSecurityQuestions;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: getMCC
  * DESC:Fetch MCC List While Registering
  * METHOD: GET
  * Params: NA
  */
  getMCC() async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.getMCC;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  Future<dynamic> GetMerchantOnboardingValues() async {
    Connection connection = Connection();
    var url =
        'http://213.42.225.250:9508/NanoPay/Middleware/UiApi/GetMerchantOnboardingValues';
    var response = await connection.get(url);
    print("Defaultvalues Api response code" + response.statusCode.toString());
    return response;

    // old merchant onboarding implimentation
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? barrertoken = prefs.getString('bearerToken');
    // print(barrertoken);
    // http.Response resonr = await http.get(
    //   Uri.parse(
    //       'http://omasoftposqc.omaemirates.com:9508/NanoPay/Middleware/UiApi/GetMerchantDefaultValues'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $barrertoken',
    //   },
    // );

    // con
    // print(resonr.body);
    // // print(prefs.getString('bearerToken') ?? 'error in reciving token');

    // // print('length  : ${acquirerDetails.length}');
    // // for (var acquirer in acquirerDetails) {
    // //   String acquirerName = acquirer['acquirerName'];
    // //   print('Acquirer Name: $acquirerName');
    // // }
    // return resonr;
  }

  Future<dynamic> getMerchantApplication(
      {required int stage, required String merchantname}) async {
    Connection connection = Connection();
    final requestBody = {"stage": stage, "merchantName": merchantname};
    var url =
        'http://213.42.225.250:9508/NanoPay/Middleware/UiApi/MerchantOnboardList';
    var response = await connection.post(url, requestBody);
    print("Defaultvalues Api response code" + response.statusCode.toString());
    return response;

    // old merchant onboarding implimentation
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? barrertoken = prefs.getString('bearerToken');
    // print(barrertoken);
    // http.Response resonr = await http.get(
    //   Uri.parse(
    //       'http://omasoftposqc.omaemirates.com:9508/NanoPay/Middleware/UiApi/GetMerchantDefaultValues'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $barrertoken',
    //   },
    // );

    // con
    // print(resonr.body);
    // // print(prefs.getString('bearerToken') ?? 'error in reciving token');

    // // print('length  : ${acquirerDetails.length}');
    // // for (var acquirer in acquirerDetails) {
    // //   String acquirerName = acquirer['acquirerName'];
    // //   print('Acquirer Name: $acquirerName');
    // // }
    // return resonr;
  }

  getAcqApplicationid(String guid) async {
    Connection connection = Connection();
    var url =
        'http://omasoftposqc.omaemirates.com:9508/NanoPay/Middleware/UiApi/GetAllAcquirerData/$guid';
    var resonr = await connection.get(url);

    // http.Response resonr = await http.get(
    //   Uri.parse(
    //       'http://omasoftposqc.omaemirates.com:9508/NanoPay/Middleware/UiApi/GetAllAcquirerData/$guid'),
    //   headers: {
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'Authorization': 'Bearer $barrertoken',
    //   },
    // );
    print('---------Get application id---------------');
    print(resonr.body);

    // print(prefs.getString('bearerToken') ?? 'error in reciving token');
    final Map<String, dynamic> data = json.decode(resonr.body);
    List<dynamic> acqApplications = data['data'];
    // List<dynamic> data = jsonResponseMap['data'];

    // print('length  : ${acqApplicationId.length}');
    // for (var acquirer in acqApplicationId) {
    //   String acquirerName = acquirer['description'];
    //   print('Acquirer Application id: $acquirerName');
    // }
    return acqApplications;
  }

  /*
  * SERVICE NAME: newCustomerSignup
  * DESC:Customer Registration
  * METHOD: POST
  * Params: RegisterRequestModel,newProfilePicture,kycFrontImage and kycBackImage
  */
  newCustomerSignup(req, pp, kf, kb) async {
    String url = EndPoints.baseApi9502 + EndPoints.registerAPI;
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['instId'] = Constants.instId;
    request.fields['notificationToken'] = req.notificationToken;
    request.fields['deviceId'] = req.deviceId;
    request.fields['userName'] = req.userName;
    request.fields['role'] = req.role;
    request.fields['password'] = req.password;
    request.fields['pin'] = req.pin;
    request.fields['mobileCountryCode'] = req.mobileCountryCode;
    request.fields['mobileNumber'] = req.mobileNumber;
    request.fields['emailId'] = req.emailId;
    request.fields['deviceType'] = Constants.deviceType;
    request.fields['questionOne'] = req.questionOne;
    request.fields['answerOne'] = req.answerOne;
    request.fields['questionTwo'] = req.questionTwo;
    request.fields['answerTwo'] = req.answerTwo;
    request.fields['questionThree'] = req.questionThree;
    request.fields['answerThree'] = req.answerThree;
    // NON-MANDATORY
    request.fields['firstName'] = req.firstName;
    request.fields['lastName'] = req.lastName;
    request.fields['dob'] = req.dob;
    request.fields['nickName'] = req.nickName;
    request.fields['country'] = req.country;
    request.fields['state'] = req.state;
    request.fields['city'] = req.city;
    request.fields['postalCode'] = req.zipCode;
    request.fields['kycType'] = "E-KYC";
    request.fields['currencyId'] = req.currencyId ?? "784";
    print("-------");
    print(request.fields['instId']);
    print(request.fields['notificationToken']);
    print(request.fields['deviceId']);
    print(request.fields['userName']);
    print(request.fields['role']);
    print(request.fields['password']);
    print(request.fields['pin']);
    print(request.fields['mobileCountryCode']);
    print(request.fields['mobileNumber']);
    print(request.fields['emailId']);
    print(request.fields['deviceType']);
    print(request.fields['questionOne']);
    print(request.fields['answerOne']);
    print(request.fields['questionTwo']);
    print(request.fields['answerTwo']);
    print(request.fields['questionThree']);
    print(request.fields['answerThree']);
    print(request.fields['firstName']);
    print(request.fields['lastName']);
    print(request.fields['dob']);
    print(request.fields['nickName']);
    print(request.fields['country']);
    print(request.fields['state']);
    print(request.fields['city']);
    print(request.fields['postalCode']);
    print(request.fields['kycType']);
    print(request.fields['currencyId']);
    final k1 = await http.MultipartFile.fromPath('file', kf);
    final k2 = await http.MultipartFile.fromPath('file', kb);
    if (pp != '') {
      final p1 = await http.MultipartFile.fromPath('profilePic', pp);
      request.files.add(p1);
    }
    print(k1);
    print(k2);
    print(pp);
    request.files.add(k1);
    request.files.add(k2);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: newMerchantSignup
  * DESC:Merchant Registration
  * METHOD: POST
  * Params: RegisterRequestModel,newProfilePicture,kycFrontImage,kycBackImage,tradeLicense,nationalIdFront,nationalIdBack and cancelCheque
  */
  newMerchantSignup(
    merchantPersonalReq,
    merchantCompanyDetailsReq,
    profilePic,
    kycFront,
    kycBack,
    tradeLicense,
    nationalIdFront,
    nationalIdBack,
    cancelCheque,
  ) async {
    //var url = EndPoints.baseApi9502 + EndPoints.registerAPI;
    BoxStorage boxStorage = BoxStorage();
    String barrertoken = boxStorage.getToken();

    var url =
        'http://omasoftposqc.omaemirates.com:9508/NanoPay/Middleware/UiApi/merchantRegistration';
    // Set up the headers
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $barrertoken', // Add any other headers you need
    };

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers);
    final kf = await http.MultipartFile.fromPath('shopLicenseFile', kycFront);
    final kb = await http.MultipartFile.fromPath('gstFile', kycBack);
    final tl = await http.MultipartFile.fromPath('poiFile', tradeLicense);
    final nf = await http.MultipartFile.fromPath('poaFile', nationalIdFront);
    final nb = await http.MultipartFile.fromPath('chequeFile', nationalIdBack);

    if (cancelCheque != '') {
      var cc =
          await http.MultipartFile.fromPath('canceledCheque', cancelCheque);
      request.files.add(cc);
    }
    // if (profilePic != '') {
    //   var pp = await http.MultipartFile.fromPath('profilePic', profilePic);
    //   request.files.add(pp);
    // }

    request.files.add(kf);
    request.files.add(kb);
    request.files.add(tl);
    request.files.add(nf);
    request.files.add(nb);

    // request.fields['instId'] = Constants.instId;
    // request.fields['notificationToken'] = req.notificationToken;
    // request.fields['deviceType'] = Constants.deviceType;
    // request.fields['deviceId'] = req.deviceId;
    // request.fields['userName'] = req.userName;
    // request.fields['firstName'] = req.firstName;
    // request.fields['lastName'] = req.lastName;
    // request.fields['nickName'] = req.nickName;
    // request.fields['password'] = req.password;
    // request.fields['pin'] = req.pin;
    // request.fields['mobileCountryCode'] = req.mobileCountryCode;
    // request.fields['mobileNumber'] = req.mobileNumber;
    // request.fields['emailId'] = req.emailId;
    // request.fields['dob'] = req.dob;
    // request.fields['role'] = req.role;
    // request.fields['questionOne'] = req.questionOne;
    // request.fields['answerOne'] = req.answerOne;
    // request.fields['questionTwo'] = req.questionTwo;
    // request.fields['answerTwo'] = req.answerTwo;
    // request.fields['questionThree'] = req.questionThree;
    // request.fields['answerThree'] = req.answerThree;
    // request.fields['country'] = req.country;
    // request.fields['state'] = req.state;
    // request.fields['city'] = req.city;
    // request.fields['latitude'] = req.latitude.toString();
    // request.fields['longitude'] = req.longitude.toString();
    // request.fields['merchantZipCode'] = req.merchantZipCode;
    // request.fields['currencyId'] = req.currencyId ?? "784";
    // request.fields['kycType'] = req.kycType ?? "E-KYC";

    // request.fields['merchantName'] = req.merchantName;
    // request.fields['mcc'] = req.mcc;
    // request.fields['businessType'] = req.businessType;
    // request.fields['companyRegNumber'] = req.companyRegNumber;
    // request.fields['nationalId'] = req.nationalId;
    // request.fields['nationalIdExpiry'] = req.nationalIdExpiry;
    // request.fields['tradeLicenseCode'] = req.tradeLicenseCode;
    // request.fields['tradeLicenseExpiry'] = req.tradeLicenseExpiry;
    // var personInfo = {
    //   "firstName": "HiFromApp",
    //   "lastName": "NewTest",
    //   "dob": "2022-11-16T20:00:00.000Z",
    //   "poiType": 1,
    //   "poiNumber": "18765432",
    //   "poiExpiryDate": "2023-11-03T20:00:00.000Z",
    //   "poaType": 1,
    //   "poaNumber": "18765432",
    //   "poaExpiryDate": "2023-11-03T20:00:00.000Z",
    //   "currentAddress": "KM Trade,Rolla",
    //   "currentCountry": 784,
    //   "permanentState": "Sharjah",
    //   "currentState": "Sharjah",
    //   "currentNationality": "Emirates",
    //   "currentMobileNo": "0567890987",
    //   "currentAltMobNo": "0567890987",
    //   "permanentAddress": "KM Trade ,Rolla",
    //   "permanentCountry": 784,
    //   "permanentZipCode": "870978",
    //   "currentZipCode": "870978"
    // };
    // var cpmpanyin = {
    //   "acquirerId": "ADIBOMA0001",
    //   "merchantId": null,
    //   "merchantName": "madhina",
    //   "merchantAddress": "Al madina Al soor",
    //   "merchantAddr2": "Rolla",
    //   "description": "test merchant",
    //   "cityCode": 2,
    //   "countryId": 784,
    //   "currency": 784,
    //   "mobileNo": "0567898765",
    //   "emailId": "subi@gmail.com",
    //   "status": true,
    //   "zipCode": "876545",
    //   "mccTypeCode": 1,
    //   "merchantLogoImage": "ADIB1.png",
    //   "commercialName": "al madina",
    //   "tradeLicenseNumber": "8765678",
    //   "tradeLicenseExpiryDate": "2023-11-03T20:00:00.000Z",
    //   "ownership": "test ownership",
    //   "shareholderPercent": "test value",
    //   "relationshipManagerId": 100,
    //   "vatApplicable": true,
    //   "vatRegistrationNumber": "98765",
    //   "vatValue": "65",
    //   "maxAuthAmount": "1000",
    //   "maxTerminalCount": "50"
    // };
    var additionalinfi = {
      "businessTypeId": 1,
      "panNo": "EYVPS3146G",
      "aadharCardNo": "626137263863",
      "gstnNo": "08CQAPM2974B1ZZ",
      "firmPanNo": "EYVPS3146G",
      "annualTurnOver": "1 to 5 cr",
      "bankAccountNo": "917558877098",
      "bankIfscCode": "PYTM0123456",
      "bankNameId": "1",
      "beneficiaryName": "Ajo Sebastian",
      "mdrType": "test",
      "latitude": 20.658745,
      "longitude": 22.354445,
      "termsCondition": true,
      "serviceAgreement": true,
      "gstnVerifyStatus": true,
      "panNumberVerifyStatus": true,
      "aadhaarNumberVerifyStatus": true,
      "firmPanNumberVerifyStatus": true,
      "merchantBankVerifyStatus": true,
      "merchantProductDetails": [
        {"productId": "1", "packagetId": "1", "qty; ": 2},
        {"productId": "2", "packagetId": "3", "qty; ": 3}
      ]
    };
    request.fields['personalInfo'] = jsonEncode(merchantPersonalReq.toJson());
    print(jsonEncode(merchantPersonalReq.toJson()));
    request.fields['companyDetailsInfo'] =
        jsonEncode(merchantCompanyDetailsReq.toJson());

    print(jsonEncode(merchantCompanyDetailsReq.toJson()));
    request.fields['merchantAdditionalInfo'] = jsonEncode(additionalinfi);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: fetchTermsAndCondition
  * DESC:Fetch Terms and Condition to Accept While Registering
  * METHOD: GET
  * Params: type
  */
  fetchTermsAndCondition(String type) async {
    Connection connection = Connection();
    var url = EndPoints.getTermsAndCondition + type;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: getUserDetails
  * DESC:Fetch User Detail
  * METHOD: GET
  * Params: Customer Id
  * to pass token in Headers
  */
  getUserDetails(customerId) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi9502}${EndPoints.getCustomerDetails}${Constants.instId}/$customerId';
    var response = await connection.get(url);
    return response;
  }

  BoxStorage boxStorage = BoxStorage();

  /*
  * SERVICE NAME: updateUserDetails
  * DESC:Update User Detail
  * METHOD: POST
  * Params: UpdateDetails
  * to pass token in Headers
  */
  updateUserDetails(updateDetails) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var custId = prefs.get('custId');
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi9502}${EndPoints.updateDetailsAPI}${Constants.instId}/$custId';
    var response = await connection.post(url, updateDetails);
    return response;
  }

  /*
  * SERVICE NAME: updatePushToken
  * DESC:Update Notification Token
  * METHOD: POST
  * Params: Notification Token
  * to pass token in Headers
  */
  updatePushToken(params) async {
    var id = boxStorage.getCustomerId();
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.updatePushToken + id;
    var response = await connection.post(url, params);
    return response;
  }

  /*
  * SERVICE NAME: uploadProfileImage
  * DESC:Update Profile Picture
  * METHOD: POST
  * Params: profilePic
  * to pass token in Headers
  */
  uploadProfileImage(image) async {
    final request = http.MultipartRequest('POST',
        Uri.parse(EndPoints.baseApi9502 + EndPoints.updateProfileImageAPI));
    final file = await http.MultipartFile.fromPath(
        'profilePic', filename: '_profilePic.jpg', image);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var custId = prefs.getString('custId')!;
    token = prefs.getString('token')!;
    final header = {'Authorization': 'Bearer $token', 'Bearer': token};
    request.headers.addAll(header);
    request.files.add(file);
    request.fields['custId'] = custId;
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: changePassword
  * DESC:Update Passcode or Pin or Mpin
  * METHOD: POST
  * Params: ChangePasswordModel
  * to pass token in Headers
  */
  changePassword(ChangePasswordModel changePasswordModel, String type) async {
    String types =
        type == 'MPIN' ? EndPoints.changeMpinAPI : EndPoints.changePasswordAPI;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = {
      'custId': prefs.get('custId'),
      'userName': prefs.get('userName'),
      'role': prefs.get('role'),
    };
    changePasswordModel.instId = Constants.instId;
    changePasswordModel.userName = user['userName'];
    changePasswordModel.deviceType = Constants.deviceType;
    changePasswordModel.role = user['role'];
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + types;
    var response = await connection.post(url, changePasswordModel);
    return response;
  }

  /*
  * SERVICE NAME: changeEmailOrMobile
  * DESC:Update Email Id or Mobile Number
  * METHOD: POST
  * Params: EmailOrMobileChangeModel
  * to pass token in Headers
  */
  changeEmailOrMobile(
      EmailOrMobileChangeModel emailOrMobileChangeModel, String? type) async {
    String types = type == 'Email ID' ? 'emailChange' : 'mobileChange';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = {
      'custId': prefs.get('custId'),
      'userName': prefs.get('userName'),
      'role': prefs.get('role'),
    };
    emailOrMobileChangeModel.instId = Constants.instId;
    emailOrMobileChangeModel.userName = user['userName'];
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.updateEmailOrMobileAPI + types;
    var response = await connection.post(url, emailOrMobileChangeModel);
    return response;
  }

  /*
  * SERVICE NAME: otpVerification
  * DESC:OTP Verification for Password/Pin/Mpin Reset
  * METHOD: POST
  * Params: loginRequestModel and Url
  * to pass token in Headers
  */
  otpVerifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = {
      'custId': prefs.get('custId'),
      'userName': prefs.get('userName'),
      'role': prefs.get('role'),
    };
    Connection connection = Connection();
    LoginRequestModel loginRequestModel = LoginRequestModel();
    var url = EndPoints.baseApi9502 + EndPoints.mobileOtpAPI;
    loginRequestModel.userName = user['userName'];
    loginRequestModel.instId = Constants.instId;
    var response = await connection.postWithOutToken(url, loginRequestModel);
    return response;
  }

  /*
  * SERVICE NAME: otpVerificationsEmail
  * DESC:OTP Verification for Update Email Id
  * METHOD: POST
  * Params: otpVerificationEmailModel
  * to pass token in Headers
  */
  otpVerificationsEmail(String? type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = {
      'custId': prefs.get('custId'),
      'userName': prefs.get('userName'),
      'role': prefs.get('role'),
    };
    Connection connection = Connection();
    OtpVerificationEmailModel otpVerificationEmailModel =
        OtpVerificationEmailModel();
    var url = EndPoints.baseApi9502 + EndPoints.mobileOtpAPI;
    otpVerificationEmailModel.userName = user['userName'];
    otpVerificationEmailModel.instId = Constants.instId;
    otpVerificationEmailModel.requestType = type;
    var response =
        await connection.postWithOutToken(url, otpVerificationEmailModel);
    return response;
  }

  /*
  * SERVICE NAME: getComplaintDetails
  * DESC:Get User Complaints Based on Customer Id
  * METHOD: GET
  * Params: type,size,customerId and instId
  * to pass token in Headers
  */

  getComplaintDetails(String type, int size1) async {
    Connection connection = Connection();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var custId = prefs.getString('custId')!;
    var customerId = '&custId=$custId';
    var instId = '&instId=${Constants.instId}';
    var size = '?size=$size1';
    var url = EndPoints.baseApi9502 +
        EndPoints.searchComplaintAPI +
        type +
        size +
        customerId +
        instId;
    var response = await connection.get(url);
    return response;
  }

  /*
  * SERVICE NAME: saveComplaintDetails
  * DESC:Save User Complaint Details
  * METHOD: POST
  * Params: type and ComplaintRequest
  * to pass token in Headers
  */
  saveComplaintDetails(ComplaintRequest complaintRequest, String type) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.addComplaintAPI + type;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = {
      'custId': prefs.get('custId'),
      'userName': prefs.get('userName'),
      'role': prefs.get('role'),
    };
    complaintRequest.custId = user['custId'];
    complaintRequest.userName = user['userName'];
    complaintRequest.instId = Constants.instId;
    var response = await connection.post(url, complaintRequest);
    return response;
  }

  /*
  * SERVICE NAME: getCountry
  * DESC:Fetch Country Details
  * METHOD: GET
  * Params:NA
  */
  getCountry() async {
    Connection connection = Connection();
    var url = EndPoints.getCountry;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: getState
  * DESC:Fetch State Details Based on Country
  * METHOD: GET
  * Params:countryId
  */
  getState(countryId) async {
    Connection connection = Connection();
    var url = EndPoints.getState + countryId;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: getCity
  * DESC:Fetch City Details Based on State
  * METHOD: GET
  * Params:stateId
  */
  getCity(stateId) async {
    Connection connection = Connection();
    var url = EndPoints.getCity + stateId;
    var response = await connection.getWithOutToken(url);
    return response;
  }

  /*
  * SERVICE NAME: getProcessFlowDetails
  * DESC:Fetch Process Flow Details
  * METHOD: GET
  * Params:customerId
  */
  getProcessFlowDetails(customerId) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi9502}${EndPoints.processFlowAPI}$customerId';
    var response = await connection.get(url);
    return response;
  }

  Future getQrCodeStatus(String qrCodeId) async {
    Connection connection = Connection();
    var url = '${EndPoints.getQrCodeStatusApi}?qrCodeId=$qrCodeId';
    print(url);
    var response = await connection.get(url);

    return response;
  }
}
