class TransactionRequest {
  String? tranDateFrom;
  String? tranDateTo;
  String? custId;
  String? accountNumber;
  String? cardReferenceNumber;

  TransactionRequest(
      {this.tranDateFrom,
      this.tranDateTo,
      this.custId,
      this.accountNumber,
      this.cardReferenceNumber});

  TransactionRequest.fromJson(Map<String, dynamic> json) {
    tranDateFrom = json['tranDateFrom'];
    tranDateTo = json['tranDateTo'];
    custId = json['custId'];
    accountNumber = json['accountNumber'];
    cardReferenceNumber = json['cardReferenceNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tranDateFrom'] = tranDateFrom;
    data['tranDateTo'] = tranDateTo;
    data['custId'] = custId;
    data['accountNumber'] = accountNumber;
    data['cardReferenceNumber'] = cardReferenceNumber;
    return data;
  }
}
