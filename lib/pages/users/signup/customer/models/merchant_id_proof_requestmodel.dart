// To parse this JSON data, do
//
//     final merchantIdProofRequestmodel = merchantIdProofRequestmodelFromJson(jsonString);

import 'dart:convert';

MerchantIdProofRequestmodel merchantIdProofRequestmodelFromJson(String str) =>
    MerchantIdProofRequestmodel.fromJson(json.decode(str));

String merchantIdProofRequestmodelToJson(MerchantIdProofRequestmodel data) =>
    json.encode(data.toJson());

class MerchantIdProofRequestmodel {
  String? panNo;
  String? aadharCardNo;
  bool panNumberVerifyStatus;
  bool aadhaarNumberVerifyStatus;

  MerchantIdProofRequestmodel({
    this.panNo,
    this.aadharCardNo,
    this.panNumberVerifyStatus = false,
    this.aadhaarNumberVerifyStatus = false,
  });

  factory MerchantIdProofRequestmodel.fromJson(Map<String, dynamic> json) =>
      MerchantIdProofRequestmodel(
        panNo: json["panNo"],
        aadharCardNo: json["aadharCardNo"],
        panNumberVerifyStatus: json["panNumberVerifyStatus"],
        aadhaarNumberVerifyStatus: json["aadhaarNumberVerifyStatus"],
      );

  Map<String, dynamic> toJson() => {
        "panNo": panNo,
        "aadharCardNo": aadharCardNo,
        "panNumberVerifyStatus": panNumberVerifyStatus,
        "aadhaarNumberVerifyStatus": aadhaarNumberVerifyStatus,
      };
}
