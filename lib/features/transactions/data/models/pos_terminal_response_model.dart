class PosTerminalResponseModel {
  final List<String> content;
  final bool first;
  final bool last;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  const PosTerminalResponseModel({
    required this.content,
    required this.first,
    required this.last,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PosTerminalResponseModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];

    return PosTerminalResponseModel(
      content: content is List ? content.map((value) => '$value').toList() : [],
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      number: json['number'] ?? 0,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}
