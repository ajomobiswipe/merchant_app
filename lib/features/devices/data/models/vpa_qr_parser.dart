class VpaQrItem {
  final String vpa;
  final String payload;
  final String payeeName;

  const VpaQrItem({
    required this.vpa,
    required this.payload,
    this.payeeName = '',
  });

  @override
  bool operator ==(Object other) {
    return other is VpaQrItem && other.vpa == vpa;
  }

  @override
  int get hashCode => vpa.hashCode;
}

class VpaQrParser {
  static List<VpaQrItem> parseContent(List<dynamic> content) {
    final seen = <String>{};
    final items = <VpaQrItem>[];

    for (final raw in content) {
      final item = parseItem(raw);
      if (item.vpa.isEmpty || seen.contains(item.vpa)) {
        continue;
      }
      seen.add(item.vpa);
      items.add(item);
    }

    return items;
  }

  static VpaQrItem parseItem(dynamic raw) {
    if (raw is Map) {
      final vpa = '${raw['vpa'] ?? ''}'.trim();
      final qrCode = '${raw['qrCode'] ?? ''}'.trim();
      final params = queryParams(qrCode);
      final payeeName = (params['pn'] ?? '').trim();

      if (vpa.isEmpty && qrCode.isEmpty) {
        return const VpaQrItem(vpa: '', payload: '');
      }

      return VpaQrItem(
        vpa: vpa.isEmpty ? (params['pa'] ?? '').trim() : vpa,
        payload: qrCode.isEmpty
            ? 'upi://pay?pa=${Uri.encodeQueryComponent(vpa)}&cu=INR'
            : qrCode,
        payeeName: payeeName,
      );
    }

    final trimmed = '$raw'.trim();
    if (trimmed.isEmpty) {
      return const VpaQrItem(vpa: '', payload: '');
    }

    final params = queryParams(trimmed);
    final vpa = (params['pa'] ?? '').trim();
    final payeeName = (params['pn'] ?? '').trim();

    if (vpa.isNotEmpty) {
      return VpaQrItem(
        vpa: vpa,
        payload: trimmed,
        payeeName: payeeName,
      );
    }

    if (!_looksLikeUpi(trimmed)) {
      return VpaQrItem(
        vpa: trimmed,
        payload: 'upi://pay?pa=${Uri.encodeQueryComponent(trimmed)}&cu=INR',
      );
    }

    return VpaQrItem(vpa: trimmed, payload: trimmed);
  }

  static Map<String, String> queryParams(String raw) {
    final queryStart = raw.indexOf('?');
    if (queryStart < 0 || queryStart == raw.length - 1) {
      return const {};
    }

    final query = raw.substring(queryStart + 1);
    final params = <String, String>{};

    for (final part in query.split('&')) {
      if (part.isEmpty) {
        continue;
      }

      final separator = part.indexOf('=');
      if (separator <= 0) {
        continue;
      }

      final key = _decode(part.substring(0, separator));
      final value = _decode(part.substring(separator + 1));
      if (key.isEmpty) {
        continue;
      }
      params[key] = value;
    }

    return params;
  }

  static bool _looksLikeUpi(String value) {
    return value.toLowerCase().startsWith('upi:');
  }

  static String _decode(String value) {
    try {
      return Uri.decodeQueryComponent(value.replaceAll('+', ' '));
    } catch (_) {
      return value;
    }
  }
}
