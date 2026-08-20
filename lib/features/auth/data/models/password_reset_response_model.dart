class PasswordResetResponseModel {
  final String responseCode;
  final String responseMessage;

  const PasswordResetResponseModel({
    required this.responseCode,
    required this.responseMessage,
  });

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      responseCode: json['responseCode']?.toString() ?? '',
      responseMessage: json['responseMessage']?.toString() ?? '',
    );
  }

  bool get isSuccess {
    final normalizedCode = responseCode.trim();
    final normalizedMessage = responseMessage.toLowerCase();

    return normalizedCode == '00' ||
        normalizedMessage.contains('success') ||
        normalizedMessage.contains('reset');
  }
}
