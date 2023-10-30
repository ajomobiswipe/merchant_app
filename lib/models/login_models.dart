class LoginRequestModel {
  String? instId;
  String? userName;
  String? pin;
  String? password;
  String? deviceType;
  String? deviceId;
  String? email;

  LoginRequestModel(
      {this.instId,
      this.userName,
      this.pin,
      this.password,
      this.deviceType,
      this.deviceId,
      this.email});

  LoginRequestModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    pin = json['pin'];
    password = json['password'];
    deviceType = json['deviceType'];
    deviceId = json['deviceId'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['pin'] = pin;
    data['password'] = password;
    data['deviceType'] = deviceType;
    data['deviceId'] = deviceId;
    data['email'] = email;
    return data;
  }
}
