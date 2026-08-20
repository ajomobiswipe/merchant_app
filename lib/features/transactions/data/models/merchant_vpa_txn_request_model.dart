class MerchantVpaTxnRequestModel {
  final String? from;
  final String? to;
  final String creditVpa;

  const MerchantVpaTxnRequestModel({
    this.from,
    this.to,
    required this.creditVpa,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from?.isEmpty == true ? null : from,
      'to': to?.isEmpty == true ? null : to,
      'creditVpa': creditVpa.isEmpty ? null : creditVpa,
    };
  }
}
