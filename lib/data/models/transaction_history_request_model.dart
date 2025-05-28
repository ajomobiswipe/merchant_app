class TransactionHistoryRequestModel {
  String? merchantId;
  String? recordFrom;
  String? recordTo;
  String? acquirerId;
  String? rrn;
  dynamic terminalId;
  bool sendTxnReportToMail;

  TransactionHistoryRequestModel({
    this.merchantId,
    this.recordFrom,
    this.recordTo,
    this.acquirerId,
    this.rrn,
    this.terminalId,
    this.sendTxnReportToMail = false,
  });

  Map<String, dynamic> toJson() => {
        "merchantId": merchantId,
        "recordFrom": recordFrom,
        "recordTo": recordTo,
        "acquirerId": acquirerId,
        "rrn": rrn,
        "terminalId": terminalId,
        "sendTxnReportToMail": sendTxnReportToMail,
      };
}
