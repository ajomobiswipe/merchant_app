class VpaQrRequestModel {
  final String merchantId;
  final bool isReconsiled;
  final bool isSettled;

  const VpaQrRequestModel({
    required this.merchantId,
    this.isReconsiled = true,
    this.isSettled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'isReconsiled': isReconsiled,
      'isSettled': isSettled,
    };
  }
}
