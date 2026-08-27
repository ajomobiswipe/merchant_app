class SettlementHistoryResponseModel {
  final SettlementPageModel settlementAggregatePage;
  final SettlementTotalModel settlementTotal;
  final SettlementPageModel settledSummaryPage;
  final SettlementSendMailResponseModel sendMailResponse;

  const SettlementHistoryResponseModel({
    required this.settlementAggregatePage,
    required this.settlementTotal,
    required this.settledSummaryPage,
    this.sendMailResponse = const SettlementSendMailResponseModel(),
  });

  factory SettlementHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return SettlementHistoryResponseModel(
      settlementAggregatePage: SettlementPageModel.fromJson(
        json['settlementAggregatePage'] ?? {},
      ),
      settlementTotal: SettlementTotalModel.fromJson(
        json['settlementTotal'] ?? {},
      ),
      settledSummaryPage: SettlementPageModel.fromJson(
        json['settledSummaryPage'] ?? {},
      ),
      sendMailResponse: SettlementSendMailResponseModel.fromJson(
        json['sendMailResponse'],
      ),
    );
  }
}

class SettlementSendMailResponseModel {
  final String responseCode;
  final String responseMessage;
  final String userName;
  final String mailId;
  final int twoFAOTPTimer;

  const SettlementSendMailResponseModel({
    this.responseCode = '',
    this.responseMessage = '',
    this.userName = '',
    this.mailId = '',
    this.twoFAOTPTimer = 0,
  });

  factory SettlementSendMailResponseModel.fromJson(dynamic json) {
    final value =
        json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return SettlementSendMailResponseModel(
      responseCode: value['responseCode']?.toString() ?? '',
      responseMessage: value['responseMessage']?.toString() ?? '',
      userName: value['userName']?.toString() ?? '',
      mailId: value['mailId']?.toString() ?? '',
      twoFAOTPTimer: _toInt(value['twoFAOTPTimer']),
    );
  }

  bool get hasMessage => responseMessage.trim().isNotEmpty;

  bool get isSuccess {
    final normalizedCode = responseCode.trim();
    final normalizedMessage = responseMessage.toLowerCase();

    return normalizedCode == '00' ||
        normalizedMessage.contains('success') ||
        normalizedMessage.contains('sent');
  }
}

class SettlementPageModel {
  final List<SettlementItemModel> content;
  final bool first;
  final bool last;
  final bool empty;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  const SettlementPageModel({
    required this.content,
    required this.first,
    required this.last,
    required this.empty,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory SettlementPageModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final pageable = json['pageable'];
    final pageableData = pageable is Map<String, dynamic> ? pageable : null;

    return SettlementPageModel(
      content: content is List
          ? content
              .whereType<Map<String, dynamic>>()
              .map(SettlementItemModel.fromJson)
              .toList()
          : [],
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? true,
      number: pageableData?['pageNumber'] ?? json['number'] ?? 0,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}

class SettlementTotalModel {
  final double totalAmount;
  final int transactionCount;
  final int settlementCount;

  const SettlementTotalModel({
    required this.totalAmount,
    required this.transactionCount,
    required this.settlementCount,
  });

  factory SettlementTotalModel.fromJson(Map<String, dynamic> json) {
    return SettlementTotalModel(
      totalAmount: _toDouble(json['totalAmount']),
      transactionCount: json['transactionCount'] ?? 0,
      settlementCount: json['settlementCount'] ?? 0,
    );
  }
}

class SettlementItemModel {
  final DateTime? tranDate;
  final String utr;
  final int transactionCount;
  final double grossTransactionAmount;
  final double totalAmountPayable;
  final double gst;
  final double mdrAmount;
  final String rrn;
  final String approveCode;
  final String mid;
  final bool merPayDone;
  final bool misDone;
  final bool reconciled;

  const SettlementItemModel({
    required this.tranDate,
    required this.utr,
    required this.transactionCount,
    required this.grossTransactionAmount,
    required this.totalAmountPayable,
    required this.gst,
    required this.mdrAmount,
    required this.rrn,
    required this.approveCode,
    required this.mid,
    required this.merPayDone,
    required this.misDone,
    required this.reconciled,
  });

  factory SettlementItemModel.fromJson(Map<String, dynamic> json) {
    return SettlementItemModel(
      tranDate: DateTime.tryParse('${json['tranDate'] ?? ''}'),
      utr: json['utr'] ?? '',
      transactionCount: json['transactionCount'] ?? 0,
      grossTransactionAmount: _toDouble(json['grossTransactionAmount']),
      totalAmountPayable: _toDouble(json['totalAmountPayable']),
      gst: _toDouble(json['gst']),
      mdrAmount: _toDouble(json['mdrAmount']),
      rrn: json['rrn'] ?? '',
      approveCode: json['approveCode'] ?? '',
      mid: json['mid'] ?? '',
      merPayDone: _toBool(json['merPayDone']),
      misDone: _toBool(json['misDone']),
      reconciled: _toBool(json['reconciled']),
    );
  }

  /// Settlement-history APIs only return completed payouts, even when
  /// merPayDone/reconciled are missing or encoded as strings.
  bool get isSettledStatus => true;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = '$value'.trim().toLowerCase();
  return text == 'true' || text == '1' || text == 'y' || text == 'yes';
}
