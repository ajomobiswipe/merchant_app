class AllTerminalsTxn {
  num totalAmount;
  int count;
  dynamic monthlyValues;
  String? serialNumber;

  AllTerminalsTxn({
    required this.totalAmount,
    required this.count,
    required this.monthlyValues,
    required this.serialNumber,
  });

  factory AllTerminalsTxn.fromJson(Map<String, dynamic> json) {
    return AllTerminalsTxn(
      totalAmount: json["totalAmount"],
      count: json["count"],
      monthlyValues: json["monthlyValues"],
      serialNumber: json["serialId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "totalAmount": totalAmount,
        "count": count,
        "monthlyValues": monthlyValues.toJson(),
      };
}
