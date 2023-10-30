class ViewBalance {
  String? transaction;
  String? instId;
  String? custId;
  String? mpin;
  String? fundSource;
  String? accountNumber;
  CardData1? cardData;

  ViewBalance(
      {this.transaction,
      this.instId,
      this.custId,
      this.mpin,
      this.fundSource,
      this.accountNumber,
      this.cardData});

  ViewBalance.fromJson(Map<String, dynamic> json) {
    transaction = json['transaction'];
    instId = json['instId'];
    custId = json['custId'];
    mpin = json['mpin'];
    fundSource = json['fundSource'];
    accountNumber = json['accountNumber'];
    cardData =
        json['cardData'] != null ? CardData1.fromJson(json['cardData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction'] = transaction;
    data['instId'] = instId;
    data['custId'] = custId;
    data['mpin'] = mpin;
    data['fundSource'] = fundSource;
    data['accountNumber'] = accountNumber;
    if (cardData != null) {
      data['cardData'] = cardData!.toJson();
    }
    return data;
  }
}

class CardData1 {
  String? cardRefrenceNumber;

  CardData1({this.cardRefrenceNumber});

  CardData1.fromJson(Map<String, dynamic> json) {
    cardRefrenceNumber = json['cardRefrenceNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cardRefrenceNumber'] = cardRefrenceNumber;
    return data;
  }
}
