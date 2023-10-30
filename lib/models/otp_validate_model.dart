class OtpValidateRequest {
  String? instId;
  String? userName;
  String? otp;

  OtpValidateRequest({this.instId, this.userName, this.otp});

  OtpValidateRequest.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['otp'] = otp;
    return data;
  }
}
