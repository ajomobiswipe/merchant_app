class ForgotPasswordResponseModel {
  final String responseCode;
  final String responseMessage;
  final String? userId;

  const ForgotPasswordResponseModel({
    required this.responseCode,
    required this.responseMessage,
    this.userId,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      responseCode: json['responseCode']?.toString() ?? '',
      responseMessage: json['responseMessage']?.toString() ?? '',
      userId: json['userId']?.toString(),
    );
  }

  bool get isSuccess => responseCode == '00';
}
