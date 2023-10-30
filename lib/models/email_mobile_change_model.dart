class EmailOrMobileChangeModel {
  String? instId;
  String? userName;
  String? mobileCountryCode;
  String? mobileNumber;
  String? newMobileNumber;
  String? emailId;
  String? newEmailId;
  String? otp;

  EmailOrMobileChangeModel(
      {this.instId,
      this.userName,
      this.mobileCountryCode,
      this.mobileNumber,
      this.newMobileNumber,
      this.newEmailId,
      this.otp,
      this.emailId});

  EmailOrMobileChangeModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    mobileCountryCode = json['mobileCountryCode'];
    mobileNumber = json['mobileNumber'];
    newMobileNumber = json['newMobileNumber'];
    newEmailId = json['newEmailId'];
    emailId = json['emailId'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['mobileCountryCode'] = mobileCountryCode;
    data['mobileNumber'] = mobileNumber;
    data['newMobileNumber'] = newMobileNumber;
    data['newEmailId'] = newEmailId;
    data['emailId'] = emailId;
    data['otp'] = otp;
    return data;
  }
}
