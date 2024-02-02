// To parse this JSON data, do
//
//     final merchantAdditionalInfoRequestmodel = merchantAdditionalInfoRequestmodelFromJson(jsonString);

import 'dart:convert';

MerchantAdditionalInfoRequestmodel merchantAdditionalInfoRequestmodelFromJson(
        String str) =>
    MerchantAdditionalInfoRequestmodel.fromJson(json.decode(str));

String merchantAdditionalInfoRequestmodelToJson(
        MerchantAdditionalInfoRequestmodel data) =>
    json.encode(data.toJson());

class MerchantAdditionalInfoRequestmodel {
  int? businessTypeId;
  String? panNo;
  String? aadharCardNo;
  String? gstnNo;
  String? firmPanNo;
  String? annualTurnOver;
  String? bankAccountNo;
  String? bankIfscCode;
  String? bankNameId;
  String? beneficiaryName;
  String? mdrType;
  double? latitude;
  double? longitude;
  bool? termsCondition;
  bool? serviceAgreement;
  List<MerchantProductDetail>? merchantProductDetails;

  MerchantAdditionalInfoRequestmodel({
    this.businessTypeId,
    this.panNo,
    this.aadharCardNo,
    this.gstnNo,
    this.firmPanNo,
    this.annualTurnOver,
    this.bankAccountNo,
    this.bankIfscCode,
    this.bankNameId,
    this.beneficiaryName,
    this.mdrType,
    this.latitude,
    this.longitude,
    this.termsCondition,
    this.serviceAgreement,
    this.merchantProductDetails,
  });

  factory MerchantAdditionalInfoRequestmodel.fromJson(
          Map<String, dynamic> json) =>
      MerchantAdditionalInfoRequestmodel(
        businessTypeId: json["businessTypeId"],
        panNo: json["panNo"],
        aadharCardNo: json["aadharCardNo"],
        gstnNo: json["gstnNo"],
        firmPanNo: json["firmPanNo"],
        annualTurnOver: json["annualTurnOver"],
        bankAccountNo: json["bankAccountNo"],
        bankIfscCode: json["bankIfscCode"],
        bankNameId: json["bankNameId"],
        beneficiaryName: json["beneficiaryName"],
        mdrType: json["mdrType"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        termsCondition: json["termsCondition"],
        serviceAgreement: json["serviceAgreement"],
        merchantProductDetails: json["merchantProductDetails"] == null
            ? []
            : List<MerchantProductDetail>.from(json["merchantProductDetails"]!
                .map((x) => MerchantProductDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "businessTypeId": businessTypeId,
        "panNo": panNo,
        "aadharCardNo": aadharCardNo,
        "gstnNo": gstnNo,
        "firmPanNo": firmPanNo,
        "annualTurnOver": annualTurnOver,
        "bankAccountNo": bankAccountNo,
        "bankIfscCode": bankIfscCode,
        "bankNameId": bankNameId,
        "beneficiaryName": beneficiaryName,
        "mdrType": mdrType,
        "latitude": latitude,
        "longitude": longitude,
        "termsCondition": termsCondition,
        "serviceAgreement": serviceAgreement,
        "merchantProductDetails": merchantProductDetails == null
            ? []
            : List<dynamic>.from(
                merchantProductDetails!.map((x) => x.toJson())),
      };
}

class MerchantProductDetail {
  String? productName;
  String? package;
  int? productId;
  int? packagetId;
  int? qty;

  MerchantProductDetail({
    this.productId,
    this.packagetId,
    this.productName,
    this.package,
    this.qty,
  });

  factory MerchantProductDetail.fromJson(Map<String, dynamic> json) =>
      MerchantProductDetail(
        productId: json["productId"],
        packagetId: json["packagetId"],
        qty: json["qty; "],
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "packagetId": packagetId,
        "qty; ": qty,
      };
}
