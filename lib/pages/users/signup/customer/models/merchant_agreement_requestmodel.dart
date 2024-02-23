// To parse this JSON data, do
//
//     final merchantAgreeMentRequestmodel = merchantAgreeMentRequestmodelFromJson(jsonString);

import 'dart:convert';

MerchantAgreeMentRequestmodel merchantAgreeMentRequestmodelFromJson(
        String str) =>
    MerchantAgreeMentRequestmodel.fromJson(json.decode(str));

String merchantAgreeMentRequestmodelToJson(
        MerchantAgreeMentRequestmodel data) =>
    json.encode(data.toJson());

class MerchantAgreeMentRequestmodel {
  int? mdrType;
  bool termsCondition;
  bool serviceAgreement;
  dynamic? mdrSummary;

  MerchantAgreeMentRequestmodel({
    this.mdrType,
    this.termsCondition = false,
    this.serviceAgreement = false,
    this.mdrSummary
  });

  factory MerchantAgreeMentRequestmodel.fromJson(Map<String, dynamic> json) =>
      MerchantAgreeMentRequestmodel(
        mdrType: json["mdrType"],
        termsCondition: json["termsCondition"],
        serviceAgreement: json["serviceAgreement"],
      );

  Map<String, dynamic> toJson() => {
        "mdrType": mdrType,
        "termsCondition": termsCondition,
        "serviceAgreement": serviceAgreement,
      };
}
