class SupportActionResponseModel {
  final String description;
  final int status;
  final List<SupportActionModel> data;

  const SupportActionResponseModel({
    required this.description,
    required this.status,
    required this.data,
  });

  factory SupportActionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return SupportActionResponseModel(
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      data: data is List
          ? data
              .whereType<Map<String, dynamic>>()
              .map(SupportActionModel.fromJson)
              .toList()
          : [],
    );
  }
}

class SupportActionModel {
  final int id;
  final String quickActionMessage;
  final String quickActionStatus;

  const SupportActionModel({
    required this.id,
    required this.quickActionMessage,
    required this.quickActionStatus,
  });

  factory SupportActionModel.fromJson(Map<String, dynamic> json) {
    return SupportActionModel(
      id: json['id'] ?? 0,
      quickActionMessage: json['quickActionMessage'] ?? '',
      quickActionStatus: json['quickActionStatus'] ?? '',
    );
  }
}
