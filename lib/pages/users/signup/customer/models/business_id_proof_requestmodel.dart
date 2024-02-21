// To parse this JSON data, do
//
//     final businessIdProofRequestmodel = businessIdProofRequestmodelFromJson(jsonString);

import 'dart:convert';

BusinessIdProofRequestmodel businessIdProofRequestmodelFromJson(String str) =>
    BusinessIdProofRequestmodel.fromJson(json.decode(str));

String businessIdProofRequestmodelToJson(BusinessIdProofRequestmodel data) =>
    json.encode(data.toJson());

class BusinessIdProofRequestmodel {
  String? gstnNo;
  String? firmPanNo;
  bool gstnVerifyStatus;
  bool firmPanNumberVerifyStatus;
  String? businessProofDocumntType;
  String? businessProofDocumtExpiry;

  BusinessIdProofRequestmodel({
    this.gstnNo,
    this.firmPanNo,
    this.gstnVerifyStatus = false,
    this.firmPanNumberVerifyStatus = false,
    this.businessProofDocumntType,
    this.businessProofDocumtExpiry,
  });

  factory BusinessIdProofRequestmodel.fromJson(Map<String, dynamic> json) =>
      BusinessIdProofRequestmodel(
        gstnNo: json["gstnNo"],
        firmPanNo: json["firmPanNo"],
        gstnVerifyStatus: json["gstnVerifyStatus"],
        firmPanNumberVerifyStatus: json["firmPanNumberVerifyStatus"],
        businessProofDocumntType: json["businessProofDocumntType"],
        businessProofDocumtExpiry: json["businessProofDocumtExpiry"],
      );

  Map<String, dynamic> toJson() => {
        "gstnNo": gstnNo,
        "firmPanNo": firmPanNo,
        "gstnVerifyStatus": gstnVerifyStatus,
        "firmPanNumberVerifyStatus": firmPanNumberVerifyStatus,
        "businessProofDocumntType": businessProofDocumntType,
        "businessProofDocumtExpiry": businessProofDocumtExpiry,
      };
}
