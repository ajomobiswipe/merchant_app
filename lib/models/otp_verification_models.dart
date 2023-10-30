class ResetPasscode {
  String? instId;
  String? pwdResetType;
  String? userName;
  String? newPin;
  String? confirmNewPin;
  String? newPassword;
  String? confirmNewPassword;
  String? otp;
  String? deviceType;
  String? role;

  ResetPasscode(
      {this.instId,
      this.pwdResetType,
      this.userName,
      this.newPin,
      this.confirmNewPin,
      this.deviceType,
      this.role,
      this.otp,
      this.newPassword,
      this.confirmNewPassword});

  ResetPasscode.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    pwdResetType = json['pwdResetType'];
    userName = json['userName'];
    newPin = json['newPin'];
    confirmNewPin = json['confirmNewPin'];
    otp = json['otp'];
    deviceType = json['deviceType'];
    role = json['role'];
    newPassword = json['newPassword'];
    confirmNewPassword = json['confirmNewPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['newPin'] = newPin;
    data['confirmNewPin'] = confirmNewPin;
    data['otp'] = otp;
    data['deviceType'] = deviceType;
    data['role'] = role;
    data['newPassword'] = newPassword;
    data['confirmNewPassword'] = confirmNewPassword;
    return data;
  }
}
