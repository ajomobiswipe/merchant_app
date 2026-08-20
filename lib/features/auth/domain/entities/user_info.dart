import 'package:equatable/equatable.dart';

class UserInfoEntry extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String shopName;
  final String responseCode;
  final String responseMessage;
  final String instId;
  final String custId;
  final String role;
  final int roleId;
  final int productId;
  final String productName;
  final String deviceType;
  final String merchantId;
  final String acqMerchantId;
  final String bearerToken;
  final bool passFlag;
  final bool checker;
  final String cid;
  final String userRoleType;
  final bool isChecker;
  final int twoFAOTPTimer;
  final String dashboardEnabled;

  const UserInfoEntry({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.shopName,
    required this.responseCode,
    required this.responseMessage,
    required this.instId,
    required this.custId,
    required this.role,
    required this.roleId,
    required this.productId,
    required this.productName,
    required this.deviceType,
    required this.merchantId,
    required this.acqMerchantId,
    required this.bearerToken,
    required this.passFlag,
    required this.checker,
    required this.cid,
    required this.userRoleType,
    required this.isChecker,
    required this.twoFAOTPTimer,
    required this.dashboardEnabled,
  });

  @override
  List<Object?> get props {
    return [
      firstName,
      lastName,
      email,
      shopName,
      responseCode,
      responseMessage,
      instId,
      custId,
      role,
      roleId,
      productId,
      productName,
      deviceType,
      merchantId,
      acqMerchantId,
      bearerToken,
      passFlag,
      checker,
      cid,
      userRoleType,
      isChecker,
      twoFAOTPTimer,
      dashboardEnabled,
    ];
  }
}
