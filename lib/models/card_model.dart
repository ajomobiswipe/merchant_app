class CardRequestModel {
  String? instId;
  String? userName;
  String? cardNumber;
  String? cvv;
  String? expiryDate;
  String? cardHolderName;

  CardRequestModel(
      {this.instId,
      this.userName,
      this.cardNumber,
      this.cvv,
      this.expiryDate,
      this.cardHolderName});

  CardRequestModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    cardNumber = json['cardNumber'];
    cvv = json['cvv'];
    expiryDate = json['expiryDate'];
    cardHolderName = json['cardHolderName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['cardNumber'] = cardNumber;
    data['cvv'] = cvv;
    data['expiryDate'] = expiryDate;
    data['cardHolderName'] = cardHolderName;
    return data;
  }
}

class CardManageRequestModel {
  String? instId;
  String? userName;
  String? cardReferenceNumber;
  String? primaryCardRefNumber;
  String? changeCardRefToPrimary;
  String? primaryAccountRefNumber;
  String? changeAccountToPrimary;
  String? primaryAccountNumber;
  String? changeAccountRefToPrimary;

  CardManageRequestModel({
    this.instId,
    this.userName,
    this.cardReferenceNumber,
    this.primaryCardRefNumber,
    this.primaryAccountRefNumber,
    this.changeCardRefToPrimary,
    this.changeAccountToPrimary,
    this.primaryAccountNumber,
    this.changeAccountRefToPrimary,
  });

  CardManageRequestModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    cardReferenceNumber = json['cardReferenceNumber'];
    primaryCardRefNumber = json['primaryCardRefNumber'];
    primaryAccountRefNumber = json['primaryAccountRefNumber'];
    changeCardRefToPrimary = json['changeCardRefToPrimary'];
    changeAccountToPrimary = json['changeAccountToPrimary'];
    primaryAccountNumber = json['primaryAccountNumber'];
    changeAccountRefToPrimary = json['changeAccountRefToPrimary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['cardReferenceNumber'] = cardReferenceNumber;
    data['primaryCardRefNumber'] = primaryCardRefNumber;
    data['primaryAccountRefNumber'] = primaryAccountRefNumber;
    data['changeCardRefToPrimary'] = changeCardRefToPrimary;
    data['changeAccountToPrimary'] = changeAccountToPrimary;
    data['primaryAccountNumber'] = primaryAccountNumber;
    data['changeAccountRefToPrimary'] = changeAccountRefToPrimary;
    return data;
  }
}
