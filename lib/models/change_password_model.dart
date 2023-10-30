class ChangePasswordModel {
  String? instId;
  String? userName;
  String? pin;
  String? mPin;
  String? newMpin;
  String? confirmNewMpin;
  String? newPin;
  String? confirmNewPin;
  String? otp;
  String? deviceType;
  String? role;
  String? password;
  String? newPassword;
  String? confirmNewPassword;

  ChangePasswordModel(
      {this.instId,
      this.userName,
      this.pin,
      this.newPin,
      this.confirmNewPin,
      this.otp,
      this.deviceType,
      this.role,
      this.newPassword,
      this.confirmNewPassword,
      this.password,
      this.mPin,
      this.newMpin,
      this.confirmNewMpin});

  ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    pin = json['pin'];
    newPin = json['newPin'];
    confirmNewPin = json['confirmNewPin'];
    otp = json['otp'];
    deviceType = json['deviceType'];
    role = json['role'];
    password = json['password'];
    newPassword = json['newPassword'];
    confirmNewPassword = json['confirmNewPassword'];
    mPin = json['mPin'];
    newMpin = json['newMpin'];
    confirmNewMpin = json['confirmNewMpin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['pin'] = pin;
    data['newPin'] = newPin;
    data['confirmNewPin'] = confirmNewPin;
    data['otp'] = otp;
    data['deviceType'] = deviceType;
    data['role'] = role;
    data['password'] = password;
    data['newPassword'] = newPassword;
    data['confirmNewPassword'] = confirmNewPassword;
    data['mPin'] = mPin;
    data['newMpin'] = newMpin;
    data['confirmNewMpin'] = confirmNewMpin;
    return data;
  }
}
