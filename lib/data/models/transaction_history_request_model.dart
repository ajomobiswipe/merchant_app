class TransactionHistoryRequestModel {
  String? merchantId;
  String? recordFrom;
  String? recordTo;
  String? acquirerId;
  String? rrn;
  String? authCode;
  dynamic terminalId;
  bool sendTxnReportToMail;

  TransactionHistoryRequestModel({
    this.merchantId,
    this.recordFrom,
    this.recordTo,
    this.acquirerId,
    this.rrn,
    this.authCode,
    this.terminalId,
    this.sendTxnReportToMail = false,
  });

  Map<String, dynamic> toJson() => {
        "merchantId": merchantId,
        "recordFrom": recordFrom,
        "recordTo": recordTo,
        "acquirerId": acquirerId,
        "rrn": rrn,
        "authCode": authCode,
        "terminalId": terminalId,
        "sendTxnReportToMail": sendTxnReportToMail,
      };
}
