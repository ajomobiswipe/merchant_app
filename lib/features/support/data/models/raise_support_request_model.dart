class RaiseSupportRequestModel {
  final String merchantId;
  final String quickActionMessage;

  const RaiseSupportRequestModel({
    required this.merchantId,
    required this.quickActionMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'quickActionMessage': quickActionMessage,
    };
  }
}
