class MerchantVpaTxnResponseModel {
  final String successMessage;
  final int statusCode;
  final MerchantVpaTxnPageDataModel pageData;
  final double totalAmount;
  final Map<String, double> monthlyUpiTxnAmount;

  const MerchantVpaTxnResponseModel({
    required this.successMessage,
    required this.statusCode,
    required this.pageData,
    required this.totalAmount,
    this.monthlyUpiTxnAmount = const {},
  });

  factory MerchantVpaTxnResponseModel.fromJson(Map<String, dynamic> json) {
    return MerchantVpaTxnResponseModel(
      successMessage: json['successMessage'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      pageData: MerchantVpaTxnPageDataModel.fromJson(json['pageData'] ?? {}),
      totalAmount: _toDouble(json['totalAmount']),
      monthlyUpiTxnAmount: _toDoubleMap(json['monthlyupiTxnAmount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static Map<String, double> _toDoubleMap(dynamic value) {
    if (value is! Map) {
      return const {};
    }

    return value.map(
      (key, amount) => MapEntry('$key', _toDouble(amount)),
    );
  }
}

class MerchantVpaTxnPageDataModel {
  final List<MerchantVpaTransactionModel> content;
  final bool first;
  final bool last;
  final bool empty;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  const MerchantVpaTxnPageDataModel({
    required this.content,
    required this.first,
    required this.last,
    required this.empty,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory MerchantVpaTxnPageDataModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];

    return MerchantVpaTxnPageDataModel(
      content: content is List
          ? content
              .whereType<Map<String, dynamic>>()
              .map(MerchantVpaTransactionModel.fromJson)
              .toList()
          : [],
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? true,
      number: json['number'] ?? 0,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}

class MerchantVpaTransactionModel {
  final String refId;
  final String name;
  final String status;
  final String transactionAmount;
  final String transactionType;
  final String accountDetailsAccType;
  final String code;
  final String payerName;
  final String payeeName;
  final String customerVpa;
  final String creditVpa;
  final String rrn;
  final String deviceId;
  final String merchantId;
  final String addedOn;
  final String orgStatus;
  final String gatewayResponseCode;
  final String gatewayResponseMessage;

  const MerchantVpaTransactionModel({
    required this.refId,
    required this.name,
    required this.status,
    required this.transactionAmount,
    required this.transactionType,
    required this.accountDetailsAccType,
    required this.code,
    required this.payerName,
    required this.payeeName,
    required this.customerVpa,
    required this.creditVpa,
    required this.rrn,
    required this.deviceId,
    required this.merchantId,
    required this.addedOn,
    this.orgStatus = '',
    this.gatewayResponseCode = '',
    this.gatewayResponseMessage = '',
  });

  factory MerchantVpaTransactionModel.fromJson(Map<String, dynamic> json) {
    final status = '${json['status'] ?? ''}';
    final code = '${json['code'] ?? ''}';
    final explicitOrgStatus =
        '${json['orgStatus'] ?? json['org_status'] ?? ''}'.trim();

    return MerchantVpaTransactionModel(
      refId: json['refId'] ?? '',
      name: json['name'] ?? '',
      status: status,
      transactionAmount: json['transactionAmount'] ?? '',
      transactionType: json['transactionType'] ?? '',
      accountDetailsAccType: json['accountDetailsAccType'] ?? '',
      code: code,
      payerName: json['payerName'] ?? '',
      payeeName: json['payeeName'] ?? '',
      customerVpa: json['customerVpa'] ?? '',
      creditVpa: json['creditVpa'] ?? '',
      rrn: json['rrn'] ?? '',
      deviceId: json['deviceId'] ?? '',
      merchantId: json['merchantId'] ?? '',
      addedOn: json['addedOn'] ?? '',
      gatewayResponseCode: '${json['gatewayResponseCode'] ?? ''}',
      gatewayResponseMessage: '${json['gatewayResponseMessage'] ?? ''}',
      orgStatus: explicitOrgStatus.isNotEmpty
          ? explicitOrgStatus
          : _derivedOrgStatus(status: status, code: code),
    );
  }

  static String _derivedOrgStatus({
    required String status,
    required String code,
  }) {
    final normalizedCode = code.trim();
    final normalizedStatus = status.trim().toLowerCase();
    if (normalizedCode == '00' ||
        normalizedCode == '000' ||
        normalizedStatus == 'success' ||
        normalizedStatus.contains('approved')) {
      return 'Success';
    }
    return '';
  }
}
