// To parse this JSON data, do
//
//     final productDeploymentRequestmodel = productDeploymentRequestmodelFromJson(jsonString);

import 'dart:convert';

ProductDeploymentRequestmodel productDeploymentRequestmodelFromJson(
        String str) =>
    ProductDeploymentRequestmodel.fromJson(json.decode(str));

String productDeploymentRequestmodelToJson(
        ProductDeploymentRequestmodel data) =>
    json.encode(data.toJson());

class ProductDeploymentRequestmodel {
  int? guid;
  String? merchantId;
  String? productId;
  String? packageId;
  String? productSerialNo;

  ProductDeploymentRequestmodel({
    this.guid,
    this.merchantId,
    this.productId,
    this.packageId,
    this.productSerialNo,
  });

  factory ProductDeploymentRequestmodel.fromJson(Map<String, dynamic> json) =>
      ProductDeploymentRequestmodel(
        guid: json["guid"],
        merchantId: json["merchantId"],
        productId: json["productId"],
        packageId: json["packageId"],
        productSerialNo: json["productSerialNo"],
      );

  Map<String, dynamic> toJson() => {
        "guid": guid,
        "merchantId": merchantId,
        "productId": productId,
        "packageId": packageId,
        "productSerialNo": productSerialNo,
      };
}
