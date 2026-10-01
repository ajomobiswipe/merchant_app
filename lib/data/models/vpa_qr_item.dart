class VpaQrItem {
  final String vpa;
  final String qrCode;

  const VpaQrItem({
    required this.vpa,
    required this.qrCode,
  });

  factory VpaQrItem.fromJson(dynamic raw) {
    if (raw is Map) {
      final vpa = '${raw['vpa'] ?? ''}'.trim();
      final qrCode = '${raw['qrCode'] ?? ''}'.trim();
      return VpaQrItem(vpa: vpa, qrCode: qrCode);
    }

    final payload = '$raw'.trim();
    return VpaQrItem(vpa: payload, qrCode: payload);
  }

  @override
  bool operator ==(Object other) => other is VpaQrItem && other.vpa == vpa;

  @override
  int get hashCode => vpa.hashCode;
}

List<VpaQrItem> parseVpaQrContent(dynamic content) {
  if (content is! List) {
    return const [];
  }

  final seen = <String>{};
  final items = <VpaQrItem>[];
  for (final raw in content) {
    final item = VpaQrItem.fromJson(raw);
    if (item.vpa.isEmpty || item.qrCode.isEmpty || seen.contains(item.vpa)) {
      continue;
    }
    seen.add(item.vpa);
    items.add(item);
  }
  return items;
}
