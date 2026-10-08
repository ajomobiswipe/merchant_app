class MerchantVpaTxnRequestModel {
  final String? from;
  final String? to;
  final String? rrn;
  final String creditVpa;
  final String? gatewayResponseCode;

  const MerchantVpaTxnRequestModel({
    this.from,
    this.to,
    this.rrn,
    required this.creditVpa,
    this.gatewayResponseCode = '00',
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from?.isEmpty == true ? null : from,
      'to': to?.isEmpty == true ? null : to,
      if (rrn != null && rrn!.trim().isNotEmpty) 'rrn': rrn!.trim(),
      'creditVpa': creditVpa.isEmpty ? null : creditVpa,
      if (gatewayResponseCode != null && gatewayResponseCode!.trim().isNotEmpty)
        'gatewayResponseCode': gatewayResponseCode!.trim(),
    };
  }
}
