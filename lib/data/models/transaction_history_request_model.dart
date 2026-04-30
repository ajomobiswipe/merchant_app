class TransactionHistoryRequestModel {
  String? merchantId;
  String? mid;
  String? recordFrom;
  String? recordTo;
  String? acquirerId;
  String? rrn;
  String? authCode;
  String? sourceOftxn;
  String? terminalId;
  String? creditVpa;
  bool sendTxnReportToMail;

  TransactionHistoryRequestModel({
    this.merchantId,
    this.mid,
    this.recordFrom,
    this.recordTo,
    this.acquirerId,
    this.rrn,
    this.authCode,
    this.sourceOftxn,
    this.terminalId,
    this.creditVpa,
    this.sendTxnReportToMail = false,
  });

  Map<String, dynamic> toJson() => {
        "merchantId": merchantId,
        "mid": mid,
        "recordFrom": recordFrom,
        "recordTo": recordTo,
        "acquirerId": acquirerId,
        "rrn": rrn,
        "authCode": authCode,
        "sourceOftxn": sourceOftxn,
        "terminalId": terminalId,
        "creditVpa": creditVpa,
        "sendTxnReportToMail": sendTxnReportToMail,
      };
}
