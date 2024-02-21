// To parse this JSON data, do
//
//     final companyDetailsInfoRequestmodel = companyDetailsInfoRequestmodelFromJson(jsonString);

import 'dart:convert';

CompanyDetailsInfoRequestmodel companyDetailsInfoRequestmodelFromJson(
        String str) =>
    CompanyDetailsInfoRequestmodel.fromJson(json.decode(str));

String companyDetailsInfoRequestmodelToJson(
        CompanyDetailsInfoRequestmodel data) =>
    json.encode(data.toJson());

class CompanyDetailsInfoRequestmodel {
  String? merchantName;
  String? merchantAddress;
  String? mobileNo;
  String? emailId;
  String? landlineNo;
  String? zipCode;
  int? mccTypeCode;
  String? commercialName;
  String? annualTurnOver;
  String? contactPerson;
  int? stateId;
  int? cityCode;
  int? businessTypeId;

  CompanyDetailsInfoRequestmodel({
    this.merchantName,
    this.merchantAddress,
    this.mobileNo,
    this.emailId,
    this.landlineNo,
    this.zipCode,
    this.mccTypeCode,
    this.commercialName,
    this.annualTurnOver,
    this.contactPerson,
    this.stateId,
    this.cityCode,
    this.businessTypeId,
  });

  factory CompanyDetailsInfoRequestmodel.fromJson(Map<String, dynamic> json) =>
      CompanyDetailsInfoRequestmodel(
        merchantName: json["merchantName"],
        merchantAddress: json["merchantAddress"],
        mobileNo: json["mobileNo"],
        emailId: json["emailId"],
        landlineNo: json["landlineNo"],
        zipCode: json["zipCode"],
        mccTypeCode: json["mccTypeCode"],
        commercialName: json["commercialName"],
        annualTurnOver: json["annualTurnOver"],
        contactPerson: json["contactPerson"],
        stateId: json["stateId"],
        cityCode: json["cityCode"],
        businessTypeId: json["businessTypeId"],
      );

  Map<String, dynamic> toJson() => {
        "merchantName": merchantName,
        "merchantAddress": merchantAddress,
        "mobileNo": mobileNo,
        "emailId": emailId,
        "landlineNo": landlineNo,
        "zipCode": zipCode,
        "mccTypeCode": mccTypeCode,
        "commercialName": commercialName,
        "annualTurnOver": annualTurnOver,
        "contactPerson": contactPerson,
        "stateId": stateId,
        "cityCode": cityCode,
        "businessTypeId": businessTypeId,
      };
}
