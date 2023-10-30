class CashAtPosRequestModel {
  String? transaction;
  String? instId;
  String? custId;
  int? mPin;
  String? fundSource;
  String? qrData;
  String? description;
  String? accountNumber;

  CashAtPosRequestModel(
      {this.transaction,
      this.instId,
      this.custId,
      this.mPin,
      this.fundSource,
      this.qrData,
      this.description,
      this.accountNumber});

  CashAtPosRequestModel.fromJson(Map<String, dynamic> json) {
    transaction = json['transaction'];
    instId = json['instId'];
    custId = json['custId'];
    mPin = json['mPin'];
    fundSource = json['fundSource'];
    qrData = json['qrData'];
    description = json['description'];
    accountNumber = json['accountNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction'] = transaction;
    data['instId'] = instId;
    data['custId'] = custId;
    data['mPin'] = mPin;
    data['fundSource'] = fundSource;
    data['qrData'] = qrData;
    data['description'] = description;
    data['accountNumber'] = accountNumber;
    return data;
  }
}

class AddMoneyModel {
  String? instId;
  String? transaction;
  String? custId;
  String? mPin;
  String? fundSource;
  String? description;
  String? accountRefNumber;
  String? amount;
  CardData? cardData;

  AddMoneyModel(
      {this.instId,
      this.transaction,
      this.custId,
      this.mPin,
      this.fundSource,
      this.description,
      this.accountRefNumber,
      this.amount,
      this.cardData});

  AddMoneyModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    transaction = json['transaction'];
    custId = json['custId'];
    mPin = json['mPin'];
    fundSource = json['fundSource'];
    description = json['description'];
    accountRefNumber = json['accountRefNumber'];
    amount = json['amount'];
    cardData =
        json['cardData'] != null ? CardData.fromJson(json['cardData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['transaction'] = transaction;
    data['custId'] = custId;
    data['mPin'] = mPin;
    data['fundSource'] = fundSource;
    data['description'] = description;
    data['accountRefNumber'] = accountRefNumber;
    data['amount'] = amount;
    if (cardData != null) {
      data['cardData'] = cardData!.toJson();
    }
    return data;
  }
}

class CardData {
  String? cardRefrenceNumber;
  String? expDate1;
  String? cvv;

  CardData({this.cardRefrenceNumber, this.expDate1, this.cvv});

  CardData.fromJson(Map<String, dynamic> json) {
    cardRefrenceNumber = json['cardRefrenceNumber'];
    expDate1 = json['expDate1'];
    cvv = json['cvv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cardRefrenceNumber'] = cardRefrenceNumber;
    data['expDate1'] = expDate1;
    data['cvv'] = cvv;
    return data;
  }
}
