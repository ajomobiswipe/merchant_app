class MPinModel {
  String? instId;
  String? requestType;
  String? custId;
  String? mPin;
  String? confirmNewMpin;
  String? newMpin;

  MPinModel(
      {this.instId,
      this.requestType,
      this.custId,
      this.mPin,
      this.confirmNewMpin,
      this.newMpin});

  MPinModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    requestType = json['requestType'];
    custId = json['custId'];
    mPin = json['mPin'];
    confirmNewMpin = json['confirmNewMpin'];
    newMpin = json['newMpin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['requestType'] = requestType;
    data['custId'] = custId;
    data['mPin'] = mPin;
    data['confirmNewMpin'] = confirmNewMpin;
    data['newMpin'] = newMpin;
    return data;
  }
}

class BalanceCheck {
  String? transaction;
  String? fundSource;
  String? custId;
  String? accountNumber;
  String? mpin;
  String? instId;

  BalanceCheck(
      {this.transaction,
      this.fundSource,
      this.custId,
      this.accountNumber,
      this.instId,
      this.mpin});

  BalanceCheck.fromJson(Map<String, dynamic> json) {
    transaction = json['transaction'];
    fundSource = json['fundSource'];
    custId = json['custId'];
    accountNumber = json['accountNumber'];
    mpin = json['mpin'];
    instId = json['instId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction'] = transaction;
    data['fundSource'] = fundSource;
    data['custId'] = custId;
    data['accountNumber'] = accountNumber;
    data['instId'] = instId;
    data['mpin'] = mpin;
    return data;
  }
}

class MPINRequest {
  String? instId;
  String? requestType;
  String? custId;
  String? newMpin;
  String? confirmNewMpin;

  MPINRequest(
      {this.instId,
      this.requestType,
      this.custId,
      this.newMpin,
      this.confirmNewMpin});

  MPINRequest.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    requestType = json['requestType'];
    custId = json['custId'];
    newMpin = json['newMpin'];
    confirmNewMpin = json['confirmNewMpin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['requestType'] = requestType;
    data['custId'] = custId;
    data['newMpin'] = newMpin;
    data['confirmNewMpin'] = confirmNewMpin;
    return data;
  }
}
