class LoginRequestModel {
  final String username;
  final String password;
  final String deviceType;

  LoginRequestModel({
    required this.username,
    required this.password,
    this.deviceType = 'MOBILE',
  });

  Map<String, dynamic> toJson() {
    return {
      // Backend login contract expects "userName" (camel-case N).
      // Sending duplicate username keys can cause inconsistent parsing
      // on some API gateways.
      'userName': username,
      'password': password,
      'deviceType': deviceType,
    };
  }
}
