import 'package:anet_merchants/features/auth/data/models/login_request_model.dart';
import 'package:anet_merchants/features/auth/data/models/otp_validation_response_model.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequestModel', () {
    test('serializes username using API contract key userName only', () {
      final request = LoginRequestModel(
        username: 'merchant_user',
        password: 'secret',
      );

      expect(request.toJson(), {
        'userName': 'merchant_user',
        'password': 'secret',
        'deviceType': 'MOBILE',
      });
      expect(request.toJson().containsKey('username'), isFalse);
    });
  });

  group('UserInfoModel', () {
    test('parses login response fields required by session and API calls', () {
      final userInfo = UserInfoModel.fromJson({
        'firstName': 'Hardwari',
        'lastName': 'Sweets',
        'userName': 'hardwarisweets',
        'emailId': 'merchant@example.com',
        'shopName': 'Hardwari Sweets Milk And Milk Products',
        'responseCode': '00',
        'responseMessage': 'Success',
        'instId': 'OMAIND',
        'custId': '216',
        'role': 'MERCHANT USER',
        'roleId': 22,
        'productId': 6,
        'productName': 'NanoPay',
        'deviceType': 'MOBAPP',
        'merchantId': 'AXISM0000001959',
        'acqMerchantId': '651010000022371',
        'bearerToken': 'token',
        'passFlag': true,
        'checker': false,
        'cid': '',
        'userRoleType': 'MERCHANT',
        'isChecker': false,
        'twoFAOTPTimer': 30,
        'dashboardEnabled': 'Y',
        'twoFARequired': false,
        'terminalId': '51169086',
        'merchantIds': {
          '651010000022371': 'Hardwari Sweets',
        },
        'merchantInfoForDashboard': [
          {
            'acqid': '651010000022372',
            'shopName': 'Branch Shop',
            'serialId': 'S1',
          },
        ],
      });

      expect(userInfo.shopName, 'Hardwari Sweets Milk And Milk Products');
      expect(userInfo.userName, 'hardwarisweets');
      expect(userInfo.merchantId, 'AXISM0000001959');
      expect(userInfo.acqMerchantId, '651010000022371');
      expect(userInfo.bearerToken, 'token');
      expect(userInfo.passFlag, isTrue);
      expect(userInfo.userType, 'merchant');
      expect(userInfo.terminalId, '51169086');
      expect(userInfo.isOtpRequired, isFalse);
      expect(userInfo.isLoginSuccess, isTrue);
      expect(userInfo.isDashboardEnabled, isTrue);
      expect(userInfo.merchantDropdownItems.length, 3);
      expect(userInfo.merchantDropdownItems[0].displayLabel, 'All');
      expect(
        userInfo.merchantDropdownItems[1].displayLabel,
        'Branch Shop - ID S1',
      );
      expect(
        userInfo.merchantDropdownItems[2].displayLabel,
        'Hardwari Sweets - ID 651010000022371',
      );
      expect(userInfo.toJson()['emailId'], 'merchant@example.com');
      expect(userInfo.toJson()['userName'], 'hardwarisweets');
    });

    test('keeps dashboard order and appends extra merchant ids', () {
      final userInfo = UserInfoModel.fromJson({
        'role': 'MERCHANT USER',
        'merchantIds': {
          '651072072300069': 'ZXPAY',
          'AXISM0000002031': 'ZXPAY',
        },
        'merchantInfoForDashboard': [
          {
            'acqid': '651072072300069',
            'shopName': 'ZXPAY',
            'serialId': '9222625864',
          },
        ],
      });

      expect(userInfo.merchantDropdownItems.length, 3);
      expect(userInfo.merchantDropdownItems[0].displayLabel, 'All');
      expect(
        userInfo.merchantDropdownItems[1].displayLabel,
        'ZXPAY - ID 9222625864',
      );
      expect(
        userInfo.merchantDropdownItems[2].displayLabel,
        'ZXPAY - ID AXISM0000002031',
      );
    });

    test('uses safe defaults for missing optional login response values', () {
      final userInfo = UserInfoModel.fromJson({});

      expect(userInfo.firstName, isEmpty);
      expect(userInfo.roleId, 0);
      expect(userInfo.productId, 0);
      expect(userInfo.passFlag, isFalse);
      expect(userInfo.twoFAOTPTimer, 0);
      expect(userInfo.twoFARequired, isFalse);
      expect(userInfo.userType, isEmpty);
      expect(userInfo.merchantDropdownItems, isEmpty);
    });

    test('accepts dashboardEnabled true values from login response', () {
      final stringFlagUser = UserInfoModel.fromJson({
        'dashboardEnabled': 'true',
      });
      final boolFlagUser = UserInfoModel.fromJson({
        'dashboardEnabled': true,
      });

      expect(stringFlagUser.dashboardEnabled, 'true');
      expect(stringFlagUser.isDashboardEnabled, isTrue);
      expect(boolFlagUser.dashboardEnabled, 'true');
      expect(boolFlagUser.isDashboardEnabled, isTrue);
    });
  });

  group('OtpValidationResponseModel', () {
    test('parses successful OTP verification response', () {
      final response = OtpValidationResponseModel.fromJson({
        'errorMessage': 'Success',
        'successMessage': 'OTP Verified successfully!',
      });

      expect(response.isSuccess, isTrue);
      expect(response.displayMessage, 'OTP Verified successfully!');
    });
  });
}

