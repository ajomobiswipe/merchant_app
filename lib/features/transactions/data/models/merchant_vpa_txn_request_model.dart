class MerchantVpaTxnRequestModel {
  final String? from;
  final String? to;
  final String? rrn;
  final String creditVpa;

  const MerchantVpaTxnRequestModel({
    this.from,
    this.to,
    this.rrn,
    required this.creditVpa,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from?.isEmpty == true ? null : from,
      'to': to?.isEmpty == true ? null : to,
      if (rrn != null && rrn!.trim().isNotEmpty) 'rrn': rrn!.trim(),
      'creditVpa': creditVpa.isEmpty ? null : creditVpa,
    };
  }
}
