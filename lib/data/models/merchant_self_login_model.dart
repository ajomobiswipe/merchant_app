class MerchantSelfLoginModel {
  String? merchantId;
  String? password;
  String? deviceType;
  String? emailOtp;
  String? mobileNumberOtp;

  // Constructor
  MerchantSelfLoginModel({
    this.merchantId,
    this.password,
    this.deviceType,
  });

  // Method to convert an instance to JSON
  Map<String, dynamic> sentOtpToJson() {
    return {
      'userName': merchantId,
      'password': password,
      'deviceType': "WEB",
    };
  }

  Map<String, dynamic> validateOtpToJson() {
    return {
      'userName': "ausoftposadmin",
      'password': "Admin@1234",
      'deviceType': "WEB",
      // 'mobileNumberOtp': mobileNumberOtp,
      // 'emailOtp': emailOtp,
      // 'deviceType': "WEB",
    };
  }

  Map<String, dynamic> validateEmailOtpToJson() {
    return {
      'userName': merchantId,
      'otp': emailOtp,
    };
  }
}
