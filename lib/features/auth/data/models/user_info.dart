class UserInfoModel {
  final String firstName;
  final String lastName;
  final String userName;
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
  final bool twoFARequired;
  final String userType;
  final String terminalId;
  final Map<String, dynamic> merchantIds;
  final List<Map<String, dynamic>> merchantInfoForDashboard;

  UserInfoModel({
    required this.firstName,
    required this.lastName,
    required this.userName,
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
    required this.twoFARequired,
    required this.userType,
    required this.terminalId,
    required this.merchantIds,
    required this.merchantInfoForDashboard,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    final role = json['role']?.toString() ?? '';
    return UserInfoModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      userName: json['userName'] ?? '',
      email: json['emailId'] ?? '',
      shopName: json['shopName'] ?? '',
      responseCode: json['responseCode'] ?? '',
      responseMessage: json['responseMessage'] ?? '',
      instId: json['instId'] ?? '',
      custId: json['custId'] ?? '',
      role: role,
      roleId: json['roleId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      deviceType: json['deviceType'] ?? '',
      merchantId: json['merchantId'] ?? '',
      acqMerchantId: json['acqMerchantId'] ?? '',
      bearerToken: json['bearerToken'] ?? '',
      passFlag: json['passFlag'] ?? false,
      checker: json['checker'] ?? false,
      cid: json['cid'] ?? '',
      userRoleType: json['userRoleType'] ?? '',
      isChecker: json['isChecker'] ?? false,
      twoFAOTPTimer: json['twoFAOTPTimer'] ?? 0,
      dashboardEnabled: json['dashboardEnabled']?.toString() ?? '',
      twoFARequired: json['twoFARequired'] == true,
      userType: json['userType']?.toString() ?? _userTypeFromRole(role),
      terminalId: json['terminalId']?.toString() ?? '',
      merchantIds: _mapFromDynamic(json['merchantIds']),
      merchantInfoForDashboard: _listOfMapsFromDynamic(
        json['merchantInfoForDashboard'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'emailId': email,
      'shopName': shopName,
      'responseCode': responseCode,
      'responseMessage': responseMessage,
      'instId': instId,
      'custId': custId,
      'role': role,
      'roleId': roleId,
      'productId': productId,
      'productName': productName,
      'deviceType': deviceType,
      'merchantId': merchantId,
      'acqMerchantId': acqMerchantId,
      'bearerToken': bearerToken,
      'passFlag': passFlag,
      'checker': checker,
      'cid': cid,
      'userRoleType': userRoleType,
      'isChecker': isChecker,
      'twoFAOTPTimer': twoFAOTPTimer,
      'dashboardEnabled': dashboardEnabled,
      'twoFARequired': twoFARequired,
      'userType': userType,
      'terminalId': terminalId,
      'merchantIds': merchantIds,
      'merchantInfoForDashboard': merchantInfoForDashboard,
    };
  }

  bool get isOtpRequired => twoFARequired;

  bool get isLoginSuccess => responseCode == '00';

  bool get isTerminalUser => role.toUpperCase() == 'TERMINAL USER';

  bool get isDashboardEnabled {
    final normalized = dashboardEnabled.trim().toLowerCase();
    return normalized == 'true' || normalized == 'y' || normalized == 'yes';
  }

  List<MerchantDropdownItem> get merchantDropdownItems {
    if (isTerminalUser) {
      return const [];
    }

    final items = <MerchantDropdownItem>[
      const MerchantDropdownItem(
        merchantId: '0',
        shopName: 'All',
      ),
    ];

    final dashboardIds = merchantInfoForDashboard
        .map(
          (item) => MerchantDropdownItem(
            merchantId: item['acqid']?.toString() ?? '',
            shopName: item['shopName']?.toString() ?? '',
            serialNo: item['serialId']?.toString(),
          ),
        )
        .where((item) => item.merchantId.isNotEmpty)
        .toList();

    items.addAll(dashboardIds);

    final dashboardIdSet = dashboardIds.map((item) => item.merchantId).toSet();
    for (final entry in merchantIds.entries) {
      if (dashboardIdSet.contains(entry.key)) {
        continue;
      }

      items.add(
        MerchantDropdownItem(
          merchantId: entry.key,
          shopName: entry.value?.toString() ?? entry.key,
        ),
      );
    }

    return items.length > 1 ? items : const [];
  }

  static String _userTypeFromRole(String role) {
    final normalizedRole = role.toUpperCase();

    if (normalizedRole == 'TERMINAL USER') {
      return 'terminal';
    }

    if (normalizedRole == 'MERCHANT' || normalizedRole == 'MERCHANT USER') {
      return 'merchant';
    }

    return normalizedRole.toLowerCase();
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return const {};
  }

  static List<Map<String, dynamic>> _listOfMapsFromDynamic(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }
}

class MerchantDropdownItem {
  final String merchantId;
  final String shopName;
  final String? serialNo;

  const MerchantDropdownItem({
    required this.merchantId,
    required this.shopName,
    this.serialNo,
  });

  bool get isAll => merchantId == '0';

  String get displayLabel {
    if (isAll) {
      return shopName;
    }

    final normalizedShopName = shopName.trim();
    final normalizedSerialNo = serialNo?.trim() ?? '';

    if (normalizedSerialNo.isNotEmpty) {
      return normalizedShopName.isEmpty
          ? 'ID $normalizedSerialNo'
          : '$normalizedShopName - ID $normalizedSerialNo';
    }

    return normalizedShopName.isEmpty
        ? merchantId
        : '$normalizedShopName - ID $merchantId';
  }
}
