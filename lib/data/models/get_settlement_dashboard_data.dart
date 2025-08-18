// To parse this JSON data, do
//
//     final getSettlementDashboardData = getSettlementDashboardDataFromJson(jsonString);

import 'dart:convert';

GetSettlementDashboardData getSettlementDashboardDataFromJson(String str) =>
    GetSettlementDashboardData.fromJson(json.decode(str));

String getSettlementDashboardDataToJson(GetSettlementDashboardData data) =>
    json.encode(data.toJson());

class GetSettlementDashboardData {
  SettledSummaryPage? settledSummaryPage;
  SettlementAggregatePage? settlementAggregatePage;
  SettlementTotal? settlementTotal;
  SendMailResponse? sendMailResponse;

  GetSettlementDashboardData({
    this.settledSummaryPage,
    this.settlementAggregatePage,
    this.settlementTotal,
    this.sendMailResponse,
  });

  factory GetSettlementDashboardData.fromJson(Map<String, dynamic> json) =>
      GetSettlementDashboardData(
        settledSummaryPage: json["settledSummaryPage"] == null
            ? null
            : SettledSummaryPage.fromJson(json["settledSummaryPage"]),
        settlementAggregatePage: json["settlementAggregatePage"] == null
            ? null
            : SettlementAggregatePage.fromJson(json["settlementAggregatePage"]),
        settlementTotal: json["settlementTotal"] == null
            ? null
            : SettlementTotal.fromJson(json["settlementTotal"]),
        sendMailResponse: json["sendMailResponse"] == null
            ? null
            : SendMailResponse.fromJson(json["sendMailResponse"]),
      );

  Map<String, dynamic> toJson() => {
        "settledSummaryPage": settledSummaryPage?.toJson(),
        "settlementAggregatePage": settlementAggregatePage?.toJson(),
        "settlementTotal": settlementTotal?.toJson(),
        "sendMailResponse": sendMailResponse?.toJson(),
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

class SettledSummaryPage {
  List<SettledSummaryPageContent>? content;
  Pageable? pageable;
  bool? last;
  int? totalElements;
  int? totalPages;
  Sort? sort;
  bool? first;
  int? numberOfElements;
  int? size;
  int? number;
  bool? empty;

  SettledSummaryPage({
    this.content,
    this.pageable,
    this.last,
    this.totalElements,
    this.totalPages,
    this.sort,
    this.first,
    this.numberOfElements,
    this.size,
    this.number,
    this.empty,
  });

  factory SettledSummaryPage.fromJson(Map<String, dynamic> json) =>
      SettledSummaryPage(
        content: json["content"] == null
            ? []
            : List<SettledSummaryPageContent>.from(json["content"]!
                .map((x) => SettledSummaryPageContent.fromJson(x))),
        pageable: json["pageable"] == null
            ? null
            : Pageable.fromJson(json["pageable"]),
        last: json["last"],
        totalElements: json["totalElements"],
        totalPages: json["totalPages"],
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        first: json["first"],
        numberOfElements: json["numberOfElements"],
        size: json["size"],
        number: json["number"],
        empty: json["empty"],
      );

  Map<String, dynamic> toJson() => {
        "content": content == null
            ? []
            : List<dynamic>.from(content!.map((x) => x.toJson())),
        "pageable": pageable?.toJson(),
        "last": last,
        "totalElements": totalElements,
        "totalPages": totalPages,
        "sort": sort?.toJson(),
        "first": first,
        "numberOfElements": numberOfElements,
        "size": size,
        "number": number,
        "empty": empty,
      };
}

class SettledSummaryPageContent {
  String? rrn;
  String? approveCode;
  DateTime? tranDate;
  bool? merPayDone;
  bool? misDone;
  String? merchantTxnIdAuthId;
  String? mid;
  String? utr;
  double? totalAmountPayable;
  double? gst;
  double? mdrAmount;
  double? grossTransactionAmount;
  bool? reconciled;

  SettledSummaryPageContent({
    this.rrn,
    this.approveCode,
    this.tranDate,
    this.merPayDone,
    this.misDone,
    this.merchantTxnIdAuthId,
    this.mid,
    this.utr,
    this.totalAmountPayable,
    this.gst,
    this.mdrAmount,
    this.grossTransactionAmount,
    this.reconciled,
  });

  factory SettledSummaryPageContent.fromJson(Map<String, dynamic> json) =>
      SettledSummaryPageContent(
        rrn: json["rrn"],
        approveCode: json["approveCode"],
        tranDate:
            json["tranDate"] == null ? null : DateTime.parse(json["tranDate"]),
        merPayDone: json["merPayDone"],
        misDone: json["misDone"],
        merchantTxnIdAuthId: json["merchantTxnIdAuthId"],
        mid: json["mid"],
        utr: json["utr"],
        totalAmountPayable: json["totalAmountPayable"]?.toDouble(),
        gst: json["gst"],
        mdrAmount: json["mdrAmount"]?.toDouble(),
        grossTransactionAmount: json["grossTransactionAmount"],
        reconciled: json["reconciled"],
      );

  Map<String, dynamic> toJson() => {
        "rrn": rrn,
        "approveCode": approveCode,
        "tranDate":
            "${tranDate!.year.toString().padLeft(4, '0')}-${tranDate!.month.toString().padLeft(2, '0')}-${tranDate!.day.toString().padLeft(2, '0')}",
        "merPayDone": merPayDone,
        "misDone": misDone,
        "merchantTxnIdAuthId": merchantTxnIdAuthId,
        "mid": mid,
        "utr": utr,
        "totalAmountPayable": totalAmountPayable,
        "gst": gst,
        "mdrAmount": mdrAmount,
        "grossTransactionAmount": grossTransactionAmount,
        "reconciled": reconciled,
      };
}

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

class SettlementAggregatePage {
  List<SettlementAggregatePageContent>? content;
  Pageable? pageable;
  bool? last;
  int? totalElements;
  int? totalPages;
  Sort? sort;
  bool? first;
  int? numberOfElements;
  int? size;
  int? number;
  bool? empty;

  SettlementAggregatePage({
    this.content,
    this.pageable,
    this.last,
    this.totalElements,
    this.totalPages,
    this.sort,
    this.first,
    this.numberOfElements,
    this.size,
    this.number,
    this.empty,
  });

  factory SettlementAggregatePage.fromJson(Map<String, dynamic> json) =>
      SettlementAggregatePage(
        content: json["content"] == null
            ? []
            : List<SettlementAggregatePageContent>.from(json["content"]!
                .map((x) => SettlementAggregatePageContent.fromJson(x))),
        pageable: json["pageable"] == null
            ? null
            : Pageable.fromJson(json["pageable"]),
        last: json["last"],
        totalElements: json["totalElements"],
        totalPages: json["totalPages"],
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        first: json["first"],
        numberOfElements: json["numberOfElements"],
        size: json["size"],
        number: json["number"],
        empty: json["empty"],
      );

  Map<String, dynamic> toJson() => {
        "content": content == null
            ? []
            : List<dynamic>.from(content!.map((x) => x.toJson())),
        "pageable": pageable?.toJson(),
        "last": last,
        "totalElements": totalElements,
        "totalPages": totalPages,
        "sort": sort?.toJson(),
        "first": first,
        "numberOfElements": numberOfElements,
        "size": size,
        "number": number,
        "empty": empty,
      };
}

class SettlementAggregatePageContent {
  DateTime? tranDate;
  double? grossTransactionAmount;
  int? transactionCount;
  String? utr;
  double? gst;
  double? mdrAmount;
  double? totalAmountPayable;

  SettlementAggregatePageContent({
    this.tranDate,
    this.grossTransactionAmount,
    this.transactionCount,
    this.utr,
    this.gst,
    this.mdrAmount,
    this.totalAmountPayable,
  });

  factory SettlementAggregatePageContent.fromJson(Map<String, dynamic> json) =>
      SettlementAggregatePageContent(
        tranDate:
            json["tranDate"] == null ? null : DateTime.parse(json["tranDate"]),
        grossTransactionAmount: json["grossTransactionAmount"]?.toDouble(),
        transactionCount: json["transactionCount"],
        utr: json["utr"],
        gst: json["gst"]?.toDouble(),
        mdrAmount: json["mdrAmount"]?.toDouble(),
        totalAmountPayable: json["totalAmountPayable"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "tranDate":
            "${tranDate!.year.toString().padLeft(4, '0')}-${tranDate!.month.toString().padLeft(2, '0')}-${tranDate!.day.toString().padLeft(2, '0')}",
        "grossTransactionAmount": grossTransactionAmount,
        "transactionCount": transactionCount,
        "utr": utr,
        "gst": gst,
        "mdrAmount": mdrAmount,
        "totalAmountPayable": totalAmountPayable,
      };
}

class SettlementTotal {
  double? totalAmount;
  int? transactionCount;
  int? settlementCount;

  SettlementTotal({
    this.totalAmount,
    this.transactionCount,
    this.settlementCount,
  });

  factory SettlementTotal.fromJson(Map<String, dynamic> json) =>
      SettlementTotal(
        totalAmount: json["totalAmount"]?.toDouble(),
        transactionCount: json["transactionCount"],
        settlementCount: json["settlementCount"],
      );

  Map<String, dynamic> toJson() => {
        "totalAmount": totalAmount,
        "transactionCount": transactionCount,
        "settlementCount": settlementCount,
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
