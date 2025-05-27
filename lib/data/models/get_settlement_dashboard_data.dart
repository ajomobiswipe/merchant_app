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
  double? totalAmount;
  int? transactionCount;
  String? utr;

  SettlementAggregate({
    this.tranDate,
    this.totalAmount,
    this.transactionCount,
    this.utr,
  });

  factory SettlementAggregate.fromJson(Map<String, dynamic> json) =>
      SettlementAggregate(
        tranDate:
            json["tranDate"] == null ? null : DateTime.parse(json["tranDate"]),
        totalAmount: json["totalAmount"]?.toDouble(),
        transactionCount: json["transactionCount"],
        utr: json["utr"],
      );

  Map<String, dynamic> toJson() => {
        "tranDate":
            "${tranDate!.year.toString().padLeft(4, '0')}-${tranDate!.month.toString().padLeft(2, '0')}-${tranDate!.day.toString().padLeft(2, '0')}",
        "totalAmount": totalAmount,
        "transactionCount": transactionCount,
        "utr": utr,
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
