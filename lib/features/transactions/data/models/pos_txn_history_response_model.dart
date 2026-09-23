class PosTxnHistoryResponseModel {
  final PosTxnPageModel responsePage;
  final double totalAmount;
  final int count;
  final Map<String, double> monthlyValues;
  final Map<String, double> sumEmiMdrValues;
  final PosSendMailResponseModel sendMailResponse;
  final List<PosTerminalSummaryModel> terminalSummaries;

  const PosTxnHistoryResponseModel({
    required this.responsePage,
    required this.totalAmount,
    required this.count,
    this.monthlyValues = const {},
    this.sumEmiMdrValues = const {},
    this.sendMailResponse = const PosSendMailResponseModel(),
    this.terminalSummaries = const [],
  });

  factory PosTxnHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final responsePage = PosTxnPageModel.fromJson(json['responsePage'] ?? {});

    return PosTxnHistoryResponseModel(
      responsePage: responsePage,
      totalAmount: _toDouble(json['totalAmount']),
      count: _toInt(json['count'], fallback: responsePage.totalElements),
      monthlyValues: _toDoubleMap(json['monthlyValues']),
      sumEmiMdrValues: _toDoubleMap(json['sumEmiMdrValues']),
      sendMailResponse: PosSendMailResponseModel.fromJson(
        _mapFromDynamic(json['sendMailResponse']),
      ),
      terminalSummaries: const [],
    );
  }

  factory PosTxnHistoryResponseModel.fromDynamic(dynamic value) {
    if (value is List) {
      return PosTxnHistoryResponseModel.fromByMidList(value);
    }

    if (value is Map) {
      return PosTxnHistoryResponseModel.fromJson(_mapFromDynamic(value));
    }

    return const PosTxnHistoryResponseModel(
      responsePage: PosTxnPageModel.empty(),
      totalAmount: 0,
      count: 0,
    );
  }

  factory PosTxnHistoryResponseModel.fromByMidList(List<dynamic> values) {
    final responses = values
        .whereType<Map>()
        .map((item) =>
            PosTxnHistoryResponseModel.fromJson(_mapFromDynamic(item)))
        .toList();

    if (responses.isEmpty) {
      return const PosTxnHistoryResponseModel(
        responsePage: PosTxnPageModel.empty(),
        totalAmount: 0,
        count: 0,
      );
    }

    final content = <PosTransactionModel>[];
    final monthlyValues = <String, double>{};
    final sumEmiMdrValues = <String, double>{};
    var totalAmount = 0.0;
    var count = 0;
    var totalPages = 0;
    var totalElements = 0;
    var first = true;
    var last = true;
    var pageNumber = 0;
    var pageSize = 0;
    var sendMailResponse = const PosSendMailResponseModel();
    final terminalSummaries = <PosTerminalSummaryModel>[];

    for (final response in responses) {
      content.addAll(response.responsePage.content);
      totalAmount += response.totalAmount;
      count += response.count;
      totalPages = response.responsePage.totalPages > totalPages
          ? response.responsePage.totalPages
          : totalPages;
      totalElements += response.responsePage.totalElements;
      first = first && response.responsePage.first;
      last = last && response.responsePage.last;
      pageNumber = response.responsePage.number;
      pageSize += response.responsePage.size;

      response.monthlyValues.forEach((month, amount) {
        monthlyValues.update(month, (current) => current + amount,
            ifAbsent: () => amount);
      });

      response.sumEmiMdrValues.forEach((month, amount) {
        sumEmiMdrValues.update(month, (current) => current + amount,
            ifAbsent: () => amount);
      });

      if (!sendMailResponse.hasMessage &&
          response.sendMailResponse.hasMessage) {
        sendMailResponse = response.sendMailResponse;
      }
    }

    for (final item in values.whereType<Map>()) {
      terminalSummaries.add(
        PosTerminalSummaryModel.fromJson(_mapFromDynamic(item)),
      );
    }

    return PosTxnHistoryResponseModel(
      responsePage: PosTxnPageModel(
        content: content,
        first: first,
        last: last,
        empty: content.isEmpty,
        number: pageNumber,
        size: pageSize == 0 ? content.length : pageSize,
        totalPages: totalPages,
        totalElements: totalElements == 0 ? count : totalElements,
      ),
      totalAmount: totalAmount,
      count: count == 0 ? totalElements : count,
      monthlyValues: monthlyValues,
      sumEmiMdrValues: sumEmiMdrValues,
      sendMailResponse: sendMailResponse,
      terminalSummaries: terminalSummaries,
    );
  }

  static Map<String, double> _toDoubleMap(dynamic value) {
    if (value is! Map) {
      return const {};
    }

    return value.map(
      (key, amount) => MapEntry('$key', _toDouble(amount)),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, value) => MapEntry('$key', value));
    }

    return const {};
  }
}

class PosTerminalSummaryModel {
  final String serialNumber;
  final int count;
  final double totalAmount;
  final Map<String, double> monthlyValues;

  const PosTerminalSummaryModel({
    required this.serialNumber,
    required this.count,
    required this.totalAmount,
    this.monthlyValues = const {},
  });

  factory PosTerminalSummaryModel.fromJson(Map<String, dynamic> json) {
    return PosTerminalSummaryModel(
      serialNumber: json['serialId']?.toString() ?? '',
      count: PosTxnHistoryResponseModel._toInt(json['count']),
      totalAmount: PosTxnHistoryResponseModel._toDouble(json['totalAmount']),
      monthlyValues: PosTxnHistoryResponseModel._toDoubleMap(
        json['monthlyValues'],
      ),
    );
  }
}

class PosTxnPageModel {
  final List<PosTransactionModel> content;
  final bool first;
  final bool last;
  final bool empty;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  const PosTxnPageModel({
    required this.content,
    required this.first,
    required this.last,
    required this.empty,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  const PosTxnPageModel.empty()
      : content = const [],
        first = true,
        last = true,
        empty = true,
        number = 0,
        size = 0,
        totalPages = 0,
        totalElements = 0;

  factory PosTxnPageModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];

    return PosTxnPageModel(
      content: content is List
          ? content
              .whereType<Map>()
              .map((item) => PosTransactionModel.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ))
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

class PosSendMailResponseModel {
  final String responseCode;
  final String responseMessage;
  final String userName;
  final String mailId;
  final int twoFAOTPTimer;

  const PosSendMailResponseModel({
    this.responseCode = '',
    this.responseMessage = '',
    this.userName = '',
    this.mailId = '',
    this.twoFAOTPTimer = 0,
  });

  factory PosSendMailResponseModel.fromJson(Map<String, dynamic> json) {
    return PosSendMailResponseModel(
      responseCode: json['responseCode']?.toString() ?? '',
      responseMessage: json['responseMessage']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      mailId: json['mailId']?.toString() ?? '',
      twoFAOTPTimer: PosTxnHistoryResponseModel._toInt(
        json['twoFAOTPTimer'],
      ),
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

class PosTransactionModel {
  final String merchantId;
  final String terminalId;
  final String transactionDate;
  final String transactionTime;
  final String rrn;
  final String amount;
  final String authCode;
  final String acquirerId;
  final String batchNo;
  final String cardNo;
  final String currency;
  final String nameOnCard;
  final String posEntryMode;
  final String responseCode;
  final String responseDesc;
  final String schemeName;
  final String stan;
  final String terminalAddress;
  final String transactionType;
  final String insertDateTime;
  final bool settled;
  final String mti;
  final String processCode;
  final bool isVoided;
  final bool isReverse;
  final String traceNumber;
  final String acquiringBin;
  final String de7;
  final String settledOn;
  final bool isBatchClosed;
  final String batchClosedOn;
  final String mcc;
  final String deviceType;
  final String txnSource;
  final String terminalLocation;

  const PosTransactionModel({
    required this.merchantId,
    required this.terminalId,
    required this.transactionDate,
    required this.transactionTime,
    required this.rrn,
    required this.amount,
    required this.authCode,
    required this.acquirerId,
    required this.batchNo,
    required this.cardNo,
    required this.currency,
    required this.nameOnCard,
    required this.posEntryMode,
    required this.responseCode,
    required this.responseDesc,
    required this.schemeName,
    required this.stan,
    required this.terminalAddress,
    required this.transactionType,
    required this.insertDateTime,
    required this.settled,
    this.mti = '',
    this.processCode = '',
    this.isVoided = false,
    this.isReverse = false,
    this.traceNumber = '',
    this.acquiringBin = '',
    this.de7 = '',
    this.settledOn = '',
    this.isBatchClosed = false,
    this.batchClosedOn = '',
    this.mcc = '',
    this.deviceType = '',
    this.txnSource = '',
    this.terminalLocation = '',
  });

  factory PosTransactionModel.fromJson(Map<String, dynamic> json) {
    return PosTransactionModel(
      merchantId: _string(json, const ['merchantId']),
      terminalId: _string(json, const ['terminalId']),
      transactionDate: _string(json, const ['transactionDate']),
      transactionTime: _string(json, const ['transactionTime']),
      rrn: _string(json, const ['rrn']),
      amount: _string(json, const ['amount']),
      authCode: _string(json, const ['authCode']),
      acquirerId: _string(json, const ['acquirerId']),
      batchNo: _string(json, const ['batchNo']),
      cardNo: _string(json, const ['cardNo']),
      currency: _string(json, const ['currency']),
      nameOnCard: _string(json, const ['nameOnCard']),
      posEntryMode: _string(json, const ['posEntryMode']),
      responseCode: _string(json, const ['responseCode']),
      responseDesc: _string(json, const ['responseDesc']),
      schemeName: _string(json, const ['schemeName']),
      stan: _string(json, const ['stan']),
      terminalAddress: _string(json, const ['terminalAddress', 'terminalLocation']),
      transactionType: _string(json, const ['transactionType']),
      insertDateTime: _string(json, const ['insertDateTime']),
      settled: _bool(json, const ['settled', 'isSettled']),
      mti: _string(json, const ['mti', 'MTI']),
      processCode: _string(json, const ['processCode', 'ProcessCode']),
      isVoided: _bool(json, const ['isVoided', 'voided']),
      isReverse: _bool(json, const ['isReverse', 'reverse']),
      traceNumber: _string(json, const ['traceNumber']),
      acquiringBin: _string(json, const ['acquiringBIN', 'acquiringBin']),
      de7: _string(json, const ['de_7', 'de7', 'DE_7']),
      settledOn: _string(json, const ['settledOn']),
      isBatchClosed: _bool(json, const ['isBatchClosed', 'batchClosed']),
      batchClosedOn: _string(json, const ['batchClosedOn']),
      mcc: _string(json, const ['mcc', 'MCC']),
      deviceType: _string(json, const ['deviceType']),
      txnSource: _string(json, const ['txnSource']),
      terminalLocation:
          _string(json, const ['terminalLocation', 'terminalAddress']),
    );
  }

  static String _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = '$value';
      if (text.trim().isEmpty || text == 'null') continue;
      return text;
    }
    return '';
  }

  static bool _bool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value == null) continue;
      final text = '$value'.trim().toLowerCase();
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
    }
    return false;
  }
}
