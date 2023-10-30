class MerchantRequest {
  String? merchantId;
  String? status;

  MerchantRequest({this.merchantId, this.status});

  MerchantRequest.fromJson(Map<String, dynamic> json) {
    merchantId = json['merchantId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['merchantId'] = merchantId;
    data['status'] = status;
    return data;
  }
}
