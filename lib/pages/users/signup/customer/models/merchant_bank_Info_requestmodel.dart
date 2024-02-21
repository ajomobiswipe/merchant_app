// To parse this JSON data, do
//
//     final merchantBankInfoRequestmodel = merchantBankInfoRequestmodelFromJson(jsonString);

import 'dart:convert';

MerchantBankInfoRequestmodel merchantBankInfoRequestmodelFromJson(String str) =>
    MerchantBankInfoRequestmodel.fromJson(json.decode(str));

String merchantBankInfoRequestmodelToJson(MerchantBankInfoRequestmodel data) =>
    json.encode(data.toJson());

class MerchantBankInfoRequestmodel {
  String? bankAccountNo;
  String? bankIfscCode;
  String? bankNameId;
  String? beneficiaryName;
  bool? merchantBankVerifyStatus;

  MerchantBankInfoRequestmodel({
    this.bankAccountNo,
    this.bankIfscCode,
    this.bankNameId,
    this.beneficiaryName,
    this.merchantBankVerifyStatus,
  });

  factory MerchantBankInfoRequestmodel.fromJson(Map<String, dynamic> json) =>
      MerchantBankInfoRequestmodel(
        bankAccountNo: json["bankAccountNo"],
        bankIfscCode: json["bankIfscCode"],
        bankNameId: json["bankNameId"],
        beneficiaryName: json["beneficiaryName"],
        merchantBankVerifyStatus: json["merchantBankVerifyStatus"],
      );

  Map<String, dynamic> toJson() => {
        "bankAccountNo": bankAccountNo,
        "bankIfscCode": bankIfscCode,
        "bankNameId": bankNameId,
        "beneficiaryName": beneficiaryName,
        "merchantBankVerifyStatus": merchantBankVerifyStatus,
      };
}
