// To parse this JSON data, do
//
//     final settledSummaryPage = settledSummaryPageFromJson(jsonString);

import 'dart:convert';

SettledSummaryPage getSettlementHistoryDataFromJson(String str) =>
    SettledSummaryPage.fromJson(json.decode(str));

String getSettlementHistoryDataToJson(SettledSummaryPage data) =>
    json.encode(data.toJson());

class SettledSummaryPage {
  SettledSummaryPageClass? settledSummaryPage;

  SettledSummaryPage({
    this.settledSummaryPage,
  });

  factory SettledSummaryPage.fromJson(Map<String, dynamic> json) =>
      SettledSummaryPage(
        settledSummaryPage: json["settledSummaryPage"] == null
            ? null
            : SettledSummaryPageClass.fromJson(json["settledSummaryPage"]),
      );

  Map<String, dynamic> toJson() => {
        "settledSummaryPage": settledSummaryPage?.toJson(),
      };
}

class SettledSummaryPageClass {
  List<SettledTransaction>? content;
  Pageable? pageable;
  bool? last;
  int? totalPages;
  int? totalElements;
  Sort? sort;
  bool? first;
  int? numberOfElements;
  int? size;
  int? number;
  bool? empty;

  SettledSummaryPageClass({
    this.content,
    this.pageable,
    this.last,
    this.totalPages,
    this.totalElements,
    this.sort,
    this.first,
    this.numberOfElements,
    this.size,
    this.number,
    this.empty,
  });

  factory SettledSummaryPageClass.fromJson(Map<String, dynamic> json) =>
      SettledSummaryPageClass(
        content: json["content"] == null
            ? []
            : List<SettledTransaction>.from(
                json["content"]!.map((x) => SettledTransaction.fromJson(x))),
        pageable: json["pageable"] == null
            ? null
            : Pageable.fromJson(json["pageable"]),
        last: json["last"],
        totalPages: json["totalPages"],
        totalElements: json["totalElements"],
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
        "totalPages": totalPages,
        "totalElements": totalElements,
        "sort": sort?.toJson(),
        "first": first,
        "numberOfElements": numberOfElements,
        "size": size,
        "number": number,
        "empty": empty,
      };
}

class SettledTransaction {
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

  SettledTransaction({
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

  factory SettledTransaction.fromJson(Map<String, dynamic> json) =>
      SettledTransaction(
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
        gst: json["gst"]?.toDouble(),
        mdrAmount: json["mdrAmount"]?.toDouble(),
        grossTransactionAmount: json["grossTransactionAmount"]?.toDouble(),
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
  int? pageSize;
  int? pageNumber;
  int? offset;
  bool? paged;
  bool? unpaged;

  Pageable({
    this.sort,
    this.pageSize,
    this.pageNumber,
    this.offset,
    this.paged,
    this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
        sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
        pageSize: json["pageSize"],
        pageNumber: json["pageNumber"],
        offset: json["offset"],
        paged: json["paged"],
        unpaged: json["unpaged"],
      );

  Map<String, dynamic> toJson() => {
        "sort": sort?.toJson(),
        "pageSize": pageSize,
        "pageNumber": pageNumber,
        "offset": offset,
        "paged": paged,
        "unpaged": unpaged,
      };
}

class Sort {
  bool? sorted;
  bool? unsorted;
  bool? empty;

  Sort({
    this.sorted,
    this.unsorted,
    this.empty,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
        sorted: json["sorted"],
        unsorted: json["unsorted"],
        empty: json["empty"],
      );

  Map<String, dynamic> toJson() => {
        "sorted": sorted,
        "unsorted": unsorted,
        "empty": empty,
      };
}
