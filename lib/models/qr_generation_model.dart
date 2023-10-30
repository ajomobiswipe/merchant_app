class GenerateQRCodeRequest {
  String? transaction;
  String? instId;
  String? terminalId;
  String? merchantId;
  String? traceNumber;
  String? amount;
  String? qrData;

  GenerateQRCodeRequest(
      {this.transaction,
      this.instId,
      this.terminalId,
      this.merchantId,
      this.traceNumber,
      this.amount,
      this.qrData});

  GenerateQRCodeRequest.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    transaction = json['transaction'];
    terminalId = json['terminalId'];
    merchantId = json['merchantId'];
    traceNumber = json['traceNumber'];
    amount = json['amount'];
    qrData = json['qrData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['transaction'] = transaction;
    data['terminalId'] = terminalId;
    data['merchantId'] = merchantId;
    data['traceNumber'] = traceNumber;
    data['amount'] = amount;
    data['qrData'] = qrData;
    return data;
  }
}


