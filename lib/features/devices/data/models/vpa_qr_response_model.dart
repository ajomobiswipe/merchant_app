import 'package:anet_merchants/features/devices/data/models/vpa_qr_parser.dart';

class VpaQrResponseModel {
  final String successMessage;
  final int statusCode;
  final VpaQrPageData pageData;

  const VpaQrResponseModel({
    required this.successMessage,
    required this.statusCode,
    required this.pageData,
  });

  factory VpaQrResponseModel.fromJson(Map<String, dynamic> json) {
    return VpaQrResponseModel(
      successMessage: json['successMessage'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      pageData: VpaQrPageData.fromJson(json['pageData'] ?? {}),
    );
  }
}

class VpaQrPageData {
  final List<VpaQrItem> content;
  final bool empty;
  final int totalElements;
  final bool last;

  const VpaQrPageData({
    required this.content,
    required this.empty,
    required this.totalElements,
    this.last = true,
  });

  factory VpaQrPageData.fromJson(Map<String, dynamic> json) {
    final content = json['content'];

    return VpaQrPageData(
      content: content is List
          ? VpaQrParser.parseContent(content)
          : const [],
      empty: json['empty'] ?? true,
      totalElements: json['totalElements'] ?? 0,
      last: json['last'] ?? true,
    );
  }
}
