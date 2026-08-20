class SoundBoxDevicesResponseModel {
  final String successMessage;
  final int statusCode;
  final SoundBoxPageDataModel pageData;

  const SoundBoxDevicesResponseModel({
    required this.successMessage,
    required this.statusCode,
    required this.pageData,
  });

  factory SoundBoxDevicesResponseModel.fromJson(Map<String, dynamic> json) {
    return SoundBoxDevicesResponseModel(
      successMessage: json['successMessage'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      pageData: SoundBoxPageDataModel.fromJson(json['pageData'] ?? {}),
    );
  }
}

class SoundBoxPageDataModel {
  final List<String> content;
  final bool empty;
  final int totalElements;

  const SoundBoxPageDataModel({
    required this.content,
    required this.empty,
    required this.totalElements,
  });

  factory SoundBoxPageDataModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];

    return SoundBoxPageDataModel(
      content: content is List ? content.map((item) => '$item').toList() : [],
      empty: json['empty'] ?? true,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}
