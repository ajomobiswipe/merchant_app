// // To parse this JSON data, do
// //
// //     final transactionHistory = transactionHistoryFromJson(jsonString);

// import 'dart:convert';

// TransactionHistory transactionHistoryFromJson(String str) =>
//     TransactionHistory.fromJson(json.decode(str));

// String transactionHistoryToJson(TransactionHistory data) =>
//     json.encode(data.toJson());

// class TransactionHistory {
//   List<TransactionElement>? content;
//   Pageable? pageable;
//   int? totalElements;
//   int? totalPages;
//   bool? last;
//   int? size;
//   int? number;
//   Sort? sort;
//   bool? first;
//   int? numberOfElements;
//   bool? empty;

//   TransactionHistory({
//     this.content,
//     this.pageable,
//     this.totalElements,
//     this.totalPages,
//     this.last,
//     this.size,
//     this.number,
//     this.sort,
//     this.first,
//     this.numberOfElements,
//     this.empty,
//   });

//   factory TransactionHistory.fromJson(Map<String, dynamic> json) =>
//       TransactionHistory(
//         content: json["content"] == null
//             ? []
//             : List<TransactionElement>.from(
//                 json["content"]!.map((x) => TransactionElement.fromJson(x))),
//         pageable: json["pageable"] == null
//             ? null
//             : Pageable.fromJson(json["pageable"]),
//         totalElements: json["totalElements"],
//         totalPages: json["totalPages"],
//         last: json["last"],
//         size: json["size"],
//         number: json["number"],
//         sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
//         first: json["first"],
//         numberOfElements: json["numberOfElements"],
//         empty: json["empty"],
//       );

//   Map<String, dynamic> toJson() => {
//         "content": content == null
//             ? []
//             : List<dynamic>.from(content!.map((x) => x.toJson())),
//         "pageable": pageable?.toJson(),
//         "totalElements": totalElements,
//         "totalPages": totalPages,
//         "last": last,
//         "size": size,
//         "number": number,
//         "sort": sort?.toJson(),
//         "first": first,
//         "numberOfElements": numberOfElements,
//         "empty": empty,
//       };
// }

// class TransactionElement {
//   String? merchantId;
//   String? acquirerId;
//   String? terminalId;
//   String? transactionDate;
//   String? transactionTime;
//   String? stan;
//   String? rrn;
//   String? amount;
//   String? authCode;
//   String? responseCode;
//   dynamic responseDesc;
//   String? transactionType;
//   dynamic mcc;
//   String? cardNo;
//   dynamic merReceiptLink;
//   dynamic custReceiptLink;
//   dynamic acquirerName;
//   String? mti;
//   String? currency;
//   int? terminalGuid;
//   int? txnGuid;
//   String? insertDateTime;
//   bool? isReverse;
//   String? batchNo;
//   String? traceNumber;
//   String? terminalLocation;
//   String? de7;
//   String? acquiringBin;
//   dynamic schemeName;
//   String? processCode;
//   dynamic p2PRequestId;
//   String? posEntryMode;
//   dynamic deviceType;
//   dynamic txnSource;
//   dynamic nameOnCard;
//   dynamic batchClosedOn;
//   dynamic settledOn;
//   bool? processAck;
//   dynamic txnResponse;
//   dynamic txnAckResponse;
//   bool? batchClosed;
//   bool? settled;
//   bool? voided;

//   TransactionElement({
//     this.merchantId,
//     this.acquirerId,
//     this.terminalId,
//     this.transactionDate,
//     this.transactionTime,
//     this.stan,
//     this.rrn,
//     this.amount,
//     this.authCode,
//     this.responseCode,
//     this.responseDesc,
//     this.transactionType,
//     this.mcc,
//     this.cardNo,
//     this.merReceiptLink,
//     this.custReceiptLink,
//     this.acquirerName,
//     this.mti,
//     this.currency,
//     this.terminalGuid,
//     this.txnGuid,
//     this.insertDateTime,
//     this.isReverse,
//     this.batchNo,
//     this.traceNumber,
//     this.terminalLocation,
//     this.de7,
//     this.acquiringBin,
//     this.schemeName,
//     this.processCode,
//     this.p2PRequestId,
//     this.posEntryMode,
//     this.deviceType,
//     this.txnSource,
//     this.nameOnCard,
//     this.batchClosedOn,
//     this.settledOn,
//     this.processAck,
//     this.txnResponse,
//     this.txnAckResponse,
//     this.batchClosed,
//     this.settled,
//     this.voided,
//   });

//   factory TransactionElement.fromJson(Map<String, dynamic> json) =>
//       TransactionElement(
//         merchantId: json["merchantId"],
//         acquirerId: json["acquirerId"],
//         terminalId: json["terminalId"],
//         transactionDate: json["transactionDate"],
//         transactionTime: json["transactionTime"],
//         stan: json["stan"],
//         rrn: json["rrn"],
//         amount: json["amount"],
//         authCode: json["authCode"],
//         responseCode: json["responseCode"],
//         responseDesc: json["responseDesc"],
//         transactionType: json["transactionType"],
//         mcc: json["mcc"],
//         cardNo: json["cardNo"],
//         merReceiptLink: json["merReceiptLink"],
//         custReceiptLink: json["custReceiptLink"],
//         acquirerName: json["acquirerName"],
//         mti: json["mti"],
//         currency: json["currency"],
//         terminalGuid: json["terminalGuid"],
//         txnGuid: json["txnGuid"],
//         insertDateTime: json["insertDateTime"],
//         isReverse: json["isReverse"],
//         batchNo: json["batchNo"],
//         traceNumber: json["traceNumber"],
//         terminalLocation: json["terminalLocation"],
//         de7: json["de_7"],
//         acquiringBin: json["acquiringBIN"],
//         schemeName: json["schemeName"],
//         processCode: json["processCode"],
//         p2PRequestId: json["p2pRequestId"],
//         posEntryMode: json["posEntryMode"],
//         deviceType: json["deviceType"],
//         txnSource: json["txnSource"],
//         nameOnCard: json["nameOnCard"],
//         batchClosedOn: json["batchClosedOn"],
//         settledOn: json["settledOn"],
//         processAck: json["processAck"],
//         txnResponse: json["txnResponse"],
//         txnAckResponse: json["txnAckResponse"],
//         batchClosed: json["batchClosed"],
//         settled: json["settled"],
//         voided: json["voided"],
//       );

//   Map<String, dynamic> toJson() => {
//         "merchantId": merchantId,
//         "acquirerId": acquirerId,
//         "terminalId": terminalId,
//         "transactionDate": transactionDate,
//         "transactionTime": transactionTime,
//         "stan": stan,
//         "rrn": rrn,
//         "amount": amount,
//         "authCode": authCode,
//         "responseCode": responseCode,
//         "responseDesc": responseDesc,
//         "transactionType": transactionType,
//         "mcc": mcc,
//         "cardNo": cardNo,
//         "merReceiptLink": merReceiptLink,
//         "custReceiptLink": custReceiptLink,
//         "acquirerName": acquirerName,
//         "mti": mti,
//         "currency": currency,
//         "terminalGuid": terminalGuid,
//         "txnGuid": txnGuid,
//         "insertDateTime": insertDateTime,
//         "isReverse": isReverse,
//         "batchNo": batchNo,
//         "traceNumber": traceNumber,
//         "terminalLocation": terminalLocation,
//         "de_7": de7,
//         "acquiringBIN": acquiringBin,
//         "schemeName": schemeName,
//         "processCode": processCode,
//         "p2pRequestId": p2PRequestId,
//         "posEntryMode": posEntryMode,
//         "deviceType": deviceType,
//         "txnSource": txnSource,
//         "nameOnCard": nameOnCard,
//         "batchClosedOn": batchClosedOn,
//         "settledOn": settledOn,
//         "processAck": processAck,
//         "txnResponse": txnResponse,
//         "txnAckResponse": txnAckResponse,
//         "batchClosed": batchClosed,
//         "settled": settled,
//         "voided": voided,
//       };
// }

// class Pageable {
//   Sort? sort;
//   int? offset;
//   int? pageSize;
//   int? pageNumber;
//   bool? paged;
//   bool? unpaged;

//   Pageable({
//     this.sort,
//     this.offset,
//     this.pageSize,
//     this.pageNumber,
//     this.paged,
//     this.unpaged,
//   });

//   factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
//         sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
//         offset: json["offset"],
//         pageSize: json["pageSize"],
//         pageNumber: json["pageNumber"],
//         paged: json["paged"],
//         unpaged: json["unpaged"],
//       );

//   Map<String, dynamic> toJson() => {
//         "sort": sort?.toJson(),
//         "offset": offset,
//         "pageSize": pageSize,
//         "pageNumber": pageNumber,
//         "paged": paged,
//         "unpaged": unpaged,
//       };
// }

// class Sort {
//   bool? sorted;
//   bool? unsorted;
//   bool? empty;

//   Sort({
//     this.sorted,
//     this.unsorted,
//     this.empty,
//   });

//   factory Sort.fromJson(Map<String, dynamic> json) => Sort(
//         sorted: json["sorted"],
//         unsorted: json["unsorted"],
//         empty: json["empty"],
//       );

//   Map<String, dynamic> toJson() => {
//         "sorted": sorted,
//         "unsorted": unsorted,
//         "empty": empty,
//       };
// }

// To parse this JSON data, do
//
//     final transactionHistory = transactionHistoryFromJson(jsonString);

import 'dart:convert';

TransactionHistory transactionHistoryFromJson(String str) =>
    TransactionHistory.fromJson(json.decode(str));

String transactionHistoryToJson(TransactionHistory data) =>
    json.encode(data.toJson());

class TransactionHistory {
  ResponsePage? responsePage;
  double? totalAmount;
  int? count;
  SendMailResponse? sendMailResponse;

  TransactionHistory({
    this.responsePage,
    this.totalAmount,
    this.count,
    this.sendMailResponse,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) =>
      TransactionHistory(
        responsePage: json["responsePage"] == null
            ? null
            : ResponsePage.fromJson(json["responsePage"]),
        totalAmount: json["totalAmount"]?.toDouble(),
        count: json["count"],
        sendMailResponse: json["sendMailResponse"] == null
            ? null
            : SendMailResponse.fromJson(json["sendMailResponse"]),
      );

  Map<String, dynamic> toJson() => {
        "responsePage": responsePage?.toJson(),
        "totalAmount": totalAmount,
        "count": count,
        "sendMailResponse": sendMailResponse?.toJson(),
      };
}

class ResponsePage {
  List<TransactionElement>? content;
  Pageable? pageable;
  int? totalElements;
  int? totalPages;
  bool? last;
  Sort? sort;
  int? numberOfElements;
  bool? first;
  int? size;
  int? number;
  bool? empty;

  ResponsePage({
    this.content,
    this.pageable,
    this.totalElements,
    this.totalPages,
    this.last,
    this.sort,
    this.numberOfElements,
    this.first,
    this.size,
    this.number,
    this.empty,
  });

  factory ResponsePage.fromJson(Map<String, dynamic> json) => ResponsePage(
        content: json["content"] == null
            ? []
            : List<TransactionElement>.from(
                json["content"]!.map((x) => TransactionElement.fromJson(x))),
        pageable: json["pageable"] == null
            ? null
            : Pageable.fromJson(json["pageable"]),
        totalElements: json["totalElements"],
        totalPages: json["totalPages"],
        last: json["last"],
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        numberOfElements: json["numberOfElements"],
        first: json["first"],
        size: json["size"],
        number: json["number"],
        empty: json["empty"],
      );

  Map<String, dynamic> toJson() => {
        "content": content == null
            ? []
            : List<dynamic>.from(content!.map((x) => x.toJson())),
        "pageable": pageable?.toJson(),
        "totalElements": totalElements,
        "totalPages": totalPages,
        "last": last,
        "sort": sort?.toJson(),
        "numberOfElements": numberOfElements,
        "first": first,
        "size": size,
        "number": number,
        "empty": empty,
      };
}

class TransactionElement {
  String? merchantId;
  Acquir? acquirerId;
  String? terminalId;
  String? transactionDate;
  String? transactionTime;
  String? stan;
  String? rrn;
  String? amount;
  String? authCode;
  String? responseCode;
  ResponseDesc? responseDesc;
  String? transactionType;
  String? mcc;
  String? cardNo;
  dynamic merReceiptLink;
  dynamic custReceiptLink;
  dynamic acquirerName;
  String? mti;
  String? currency;
  int? terminalGuid;
  int? txnGuid;
  String? insertDateTime;
  String? batchNo;
  String? traceNumber;
  TerminalLocation? terminalLocation;
  String? de7;
  Acquir? acquiringBin;
  dynamic schemeName;
  String? processCode;
  dynamic p2PRequestId;
  String? posEntryMode;
  DeviceType? deviceType;
  TxnSource? txnSource;
  String? nameOnCard;
  String? batchClosedOn;
  String? settledOn;
  bool? processAck;
  dynamic txnResponse;
  dynamic txnAckResponse;
  bool? settled;
  bool? batchClosed;
  bool? reverse;
  bool? voided;

  TransactionElement({
    this.merchantId,
    this.acquirerId,
    this.terminalId,
    this.transactionDate,
    this.transactionTime,
    this.stan,
    this.rrn,
    this.amount,
    this.authCode,
    this.responseCode,
    this.responseDesc,
    this.transactionType,
    this.mcc,
    this.cardNo,
    this.merReceiptLink,
    this.custReceiptLink,
    this.acquirerName,
    this.mti,
    this.currency,
    this.terminalGuid,
    this.txnGuid,
    this.insertDateTime,
    this.batchNo,
    this.traceNumber,
    this.terminalLocation,
    this.de7,
    this.acquiringBin,
    this.schemeName,
    this.processCode,
    this.p2PRequestId,
    this.posEntryMode,
    this.deviceType,
    this.txnSource,
    this.nameOnCard,
    this.batchClosedOn,
    this.settledOn,
    this.processAck,
    this.txnResponse,
    this.txnAckResponse,
    this.settled,
    this.batchClosed,
    this.reverse,
    this.voided,
  });

  factory TransactionElement.fromJson(Map<String, dynamic> json) =>
      TransactionElement(
        merchantId: json["merchantId"],
        acquirerId: acquirValues.map[json["acquirerId"]],
        terminalId: json["terminalId"],
        transactionDate: json["transactionDate"],
        transactionTime: json["transactionTime"],
        stan: json["stan"],
        rrn: json["rrn"],
        amount: json["amount"],
        authCode: json["authCode"],
        responseCode: json["responseCode"],
        responseDesc: responseDescValues.map[json["responseDesc"]],
        transactionType: json["transactionType"],
        mcc: json["mcc"],
        cardNo: json["cardNo"],
        merReceiptLink: json["merReceiptLink"],
        custReceiptLink: json["custReceiptLink"],
        acquirerName: json["acquirerName"],
        mti: json["mti"],
        currency: json["currency"],
        terminalGuid: json["terminalGuid"],
        txnGuid: json["txnGuid"],
        insertDateTime: json["insertDateTime"],
        batchNo: json["batchNo"],
        traceNumber: json["traceNumber"],
        terminalLocation: terminalLocationValues.map[json["terminalLocation"]],
        de7: json["de_7"],
        acquiringBin: acquirValues.map[json["acquiringBIN"]],
        schemeName: json["schemeName"],
        processCode: json["processCode"],
        p2PRequestId: json["p2pRequestId"],
        posEntryMode: json["posEntryMode"],
        deviceType: deviceTypeValues.map[json["deviceType"]],
        txnSource: txnSourceValues.map[json["txnSource"]],
        nameOnCard: json["nameOnCard"],
        batchClosedOn: json["batchClosedOn"],
        settledOn: json["settledOn"],
        processAck: json["processAck"],
        txnResponse: json["txnResponse"],
        txnAckResponse: json["txnAckResponse"],
        settled: json["settled"],
        batchClosed: json["batchClosed"],
        reverse: json["reverse"],
        voided: json["voided"],
      );

  Map<String, dynamic> toJson() => {
        "merchantId": merchantId,
        "acquirerId": acquirValues.reverse[acquirerId],
        "terminalId": terminalId,
        "transactionDate": transactionDate,
        "transactionTime": transactionTime,
        "stan": stan,
        "rrn": rrn,
        "amount": amount,
        "authCode": authCode,
        "responseCode": responseCode,
        "responseDesc": responseDescValues.reverse[responseDesc],
        "transactionType": transactionType,
        "mcc": mcc,
        "cardNo": cardNo,
        "merReceiptLink": merReceiptLink,
        "custReceiptLink": custReceiptLink,
        "acquirerName": acquirerName,
        "mti": mti,
        "currency": currency,
        "terminalGuid": terminalGuid,
        "txnGuid": txnGuid,
        "insertDateTime": insertDateTime,
        "batchNo": batchNo,
        "traceNumber": traceNumber,
        "terminalLocation": terminalLocationValues.reverse[terminalLocation],
        "de_7": de7,
        "acquiringBIN": acquirValues.reverse[acquiringBin],
        "schemeName": schemeName,
        "processCode": processCode,
        "p2pRequestId": p2PRequestId,
        "posEntryMode": posEntryMode,
        "deviceType": deviceTypeValues.reverse[deviceType],
        "txnSource": txnSourceValues.reverse[txnSource],
        "nameOnCard": nameOnCard,
        "batchClosedOn": batchClosedOn,
        "settledOn": settledOn,
        "processAck": processAck,
        "txnResponse": txnResponse,
        "txnAckResponse": txnAckResponse,
        "settled": settled,
        "batchClosed": batchClosed,
        "reverse": reverse,
        "voided": voided,
      };
}

enum Acquir { OMAIND }

final acquirValues = EnumValues({"OMAIND": Acquir.OMAIND});

enum DeviceType { ANDROID_POS }

final deviceTypeValues = EnumValues({"ANDROID POS": DeviceType.ANDROID_POS});

enum ResponseDesc { INVALID_AMOUNT, SUCCESS, TRANSACTION_CANNOT_BE_COMPLETED }

final responseDescValues = EnumValues({
  "INVALID AMOUNT": ResponseDesc.INVALID_AMOUNT,
  "SUCCESS": ResponseDesc.SUCCESS,
  "TRANSACTION CANNOT BE COMPLETED":
      ResponseDesc.TRANSACTION_CANNOT_BE_COMPLETED
});

enum TerminalLocation { HARDWARI_SWEETS_MILK_ADELHI_DL_IN }

final terminalLocationValues = EnumValues({
  "HARDWARI SWEETS MILK ADELHI        DL IN":
      TerminalLocation.HARDWARI_SWEETS_MILK_ADELHI_DL_IN
});

enum TxnSource { CARD }

final txnSourceValues = EnumValues({"CARD": TxnSource.CARD});

class Pageable {
  Sort? sort;
  int? pageNumber;
  int? pageSize;
  int? offset;
  bool? paged;
  bool? unpaged;

  Pageable({
    this.sort,
    this.pageNumber,
    this.pageSize,
    this.offset,
    this.paged,
    this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        pageNumber: json["pageNumber"],
        pageSize: json["pageSize"],
        offset: json["offset"],
        paged: json["paged"],
        unpaged: json["unpaged"],
      );

  Map<String, dynamic> toJson() => {
        "sort": sort?.toJson(),
        "pageNumber": pageNumber,
        "pageSize": pageSize,
        "offset": offset,
        "paged": paged,
        "unpaged": unpaged,
      };
}

class Sort {
  bool? unsorted;
  bool? sorted;
  bool? empty;

  Sort({
    this.unsorted,
    this.sorted,
    this.empty,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
        unsorted: json["unsorted"],
        sorted: json["sorted"],
        empty: json["empty"],
      );

  Map<String, dynamic> toJson() => {
        "unsorted": unsorted,
        "sorted": sorted,
        "empty": empty,
      };
}

class SendMailResponse {
  dynamic responseCode;
  dynamic responseMessage;
  dynamic userName;
  dynamic mailId;
  int? twoFaotpTimer;

  SendMailResponse({
    this.responseCode,
    this.responseMessage,
    this.userName,
    this.mailId,
    this.twoFaotpTimer,
  });

  factory SendMailResponse.fromJson(Map<String, dynamic> json) =>
      SendMailResponse(
        responseCode: json["responseCode"],
        responseMessage: json["responseMessage"],
        userName: json["userName"],
        mailId: json["mailId"],
        twoFaotpTimer: json["twoFAOTPTimer"],
      );

  Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "responseMessage": responseMessage,
        "userName": userName,
        "mailId": mailId,
        "twoFAOTPTimer": twoFaotpTimer,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
