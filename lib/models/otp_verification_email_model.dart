class OtpVerificationEmailModel {
  String? instId;
  String? userName;
  String? pin;
  String? password;
  String? deviceType;
  String? email;
  String? requestType;

  OtpVerificationEmailModel(
      {this.instId,
      this.userName,
      this.pin,
      this.password,
      this.deviceType,
      this.requestType,
      this.email});

  OtpVerificationEmailModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    pin = json['pin'];
    password = json['password'];
    deviceType = json['deviceType'];
    email = json['email'];
    requestType = json['requestType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['pin'] = pin;
    data['password'] = password;
    data['deviceType'] = deviceType;
    data['email'] = email;
    data['requestType'] = requestType;
    return data;
  }
}
