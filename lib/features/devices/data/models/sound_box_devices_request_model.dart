class SoundBoxDevicesRequestModel {
  final String merchantId;

  const SoundBoxDevicesRequestModel({
    required this.merchantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
    };
  }
}
