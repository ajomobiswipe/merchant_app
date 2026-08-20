class OtpValidationResponseModel {
  final String responseCode;
  final String responseMessage;
  final String successMessage;
  final String errorMessage;

  const OtpValidationResponseModel({
    required this.responseCode,
    required this.responseMessage,
    required this.successMessage,
    required this.errorMessage,
  });

  factory OtpValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpValidationResponseModel(
      responseCode: json['responseCode']?.toString() ?? '',
      responseMessage: json['responseMessage']?.toString() ?? '',
      successMessage: json['successMessage']?.toString() ?? '',
      errorMessage: json['errorMessage']?.toString() ?? '',
    );
  }

  bool get isSuccess {
    return responseCode == '00' ||
        successMessage.trim().isNotEmpty ||
        errorMessage.trim().toLowerCase() == 'success';
  }

  String get displayMessage {
    if (successMessage.trim().isNotEmpty) {
      return successMessage;
    }

    if (responseMessage.trim().isNotEmpty) {
      return responseMessage;
    }

    return errorMessage;
  }
}
