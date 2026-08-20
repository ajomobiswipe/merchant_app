class RaiseSupportResponseModel {
  final String description;
  final int status;
  final String message;

  const RaiseSupportResponseModel({
    required this.description,
    required this.status,
    required this.message,
  });

  factory RaiseSupportResponseModel.fromJson(Map<String, dynamic> json) {
    return RaiseSupportResponseModel(
      description: json['description'] ?? '',
      status: json['status'] ?? json['statusCode'] ?? 0,
      message: json['message'] ?? json['successMessage'] ?? '',
    );
  }
}
