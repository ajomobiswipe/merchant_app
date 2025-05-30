// To parse this JSON data, do
//
//     final getSettlementDashboardData = getSettlementDashboardDataFromJson(jsonString);

import 'dart:convert';

GetSettlementDashboardData getSettlementDashboardDataFromJson(String str) =>
    GetSettlementDashboardData.fromJson(json.decode(str));

String getSettlementDashboardDataToJson(GetSettlementDashboardData data) =>
    json.encode(data.toJson());

class GetSettlementDashboardData {
  List<SettlementAggregate>? settlementAggregates;
  SettlementTotal? settlementTotal;

  GetSettlementDashboardData({
    this.settlementAggregates,
    this.settlementTotal,
  });

  factory GetSettlementDashboardData.fromJson(Map<String, dynamic> json) =>
      GetSettlementDashboardData(
        settlementAggregates: json["settlementAggregates"] == null
            ? []
            : List<SettlementAggregate>.from(json["settlementAggregates"]!
                .map((x) => SettlementAggregate.fromJson(x))),
        settlementTotal: json["settlementTotal"] == null
            ? null
            : SettlementTotal.fromJson(json["settlementTotal"]),
      );

  Map<String, dynamic> toJson() => {
        "settlementAggregates": settlementAggregates == null
            ? []
            : List<dynamic>.from(settlementAggregates!.map((x) => x.toJson())),
        "settlementTotal": settlementTotal?.toJson(),
      };
}

class SettlementAggregate {
  DateTime? tranDate;
  double? grossTransactionAmount;
  double? totalAmountPayable;
  int? transactionCount;
  String? utr;
  double? gst;
  double? mdrAmount;
  double? settlementAmount;

  SettlementAggregate({
    this.tranDate,
    this.grossTransactionAmount,
    this.totalAmountPayable,
    this.transactionCount,
    this.utr,
    this.gst,
    this.mdrAmount,
    this.settlementAmount,
  });

  factory SettlementAggregate.fromJson(Map<String, dynamic> json) =>
      SettlementAggregate(
        tranDate:
            json["tranDate"] == null ? null : DateTime.parse(json["tranDate"]),
        grossTransactionAmount: json["grossTransactionAmount"]?.toDouble(),
        transactionCount: json["transactionCount"],
        utr: json["utr"],
        gst: json["gst"]?.toDouble(),
        mdrAmount: json["mdrAmount"]?.toDouble(),
        settlementAmount: json["settlementAmount"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "tranDate":
            "${tranDate!.year.toString().padLeft(4, '0')}-${tranDate!.month.toString().padLeft(2, '0')}-${tranDate!.day.toString().padLeft(2, '0')}",
        "grossTransactionAmount": grossTransactionAmount,
        "transactionCount": transactionCount,
        "utr": utr,
        "gst": gst,
        "mdrAmount": mdrAmount,
        "settlementAmount": settlementAmount,
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
