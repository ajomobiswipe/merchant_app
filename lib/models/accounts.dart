class AccountRequestModel {
  String? instId;
  String? userName;
  String? accountNumber;
  String? accountReferenceNumber;
  String? accountHolderName;
  String? confirmAccountNumber;
  String? changeAccountToPrimary;
  String? primaryCardRefNumber;
  String? primaryAccountRefNumber;
  String? changeAccountRefToPrimary;
  String? primaryAccountNumber;
  String? ibanNumber;
  String? cardNumber;
  String? cvv;
  String? expiryDate;

  AccountRequestModel(
      {this.instId,
      this.userName,
      this.accountNumber,
      this.accountReferenceNumber,
      this.primaryAccountRefNumber,
      this.changeAccountRefToPrimary,
      this.accountHolderName,
      this.confirmAccountNumber,
      this.changeAccountToPrimary,
      this.primaryCardRefNumber,
      this.primaryAccountNumber,
      this.ibanNumber,
      this.cardNumber,
      this.expiryDate,
      this.cvv});

  AccountRequestModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    accountNumber = json['accountNumber'];
    accountReferenceNumber = json['accountReferenceNumber'];
    changeAccountRefToPrimary = json['changeAccountRefToPrimary'];
    primaryAccountRefNumber = json['primaryAccountRefNumber'];
    accountHolderName = json['accountHolderName'];
    confirmAccountNumber = json['confirmAccountNumber'];
    changeAccountToPrimary = json['changeAccountToPrimary'];
    primaryCardRefNumber = json['primaryCardRefNumber'];
    primaryAccountNumber = json['primaryAccountNumber'];
    ibanNumber = json['ibanNumber'];
    cardNumber = json['cardNumber'];
    expiryDate = json['expiryDate'];
    cvv = json['cvv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['accountNumber'] = accountNumber;
    data['accountReferenceNumber'] = accountReferenceNumber;
    data['changeAccountRefToPrimary'] = changeAccountRefToPrimary;
    data['primaryAccountRefNumber'] = primaryAccountRefNumber;
    data['accountHolderName'] = accountHolderName;
    data['confirmAccountNumber'] = confirmAccountNumber;
    data['changeAccountToPrimary'] = changeAccountToPrimary;
    data['primaryCardRefNumber'] = primaryCardRefNumber;
    data['primaryAccountNumber'] = primaryAccountNumber;
    data['ibanNumber'] = ibanNumber;
    data['cardNumber'] = cardNumber;
    data['expiryDate'] = expiryDate;
    data['cvv'] = cvv;
    return data;
  }
}
