import 'dart:convert';

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
  bool? termsCondition;
  bool? serviceAgreement;
  List<MerchantProductDetails> merchantProductDetails;

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
    this.termsCondition,
    this.serviceAgreement,
    required this.merchantProductDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessTypeId': businessTypeId,
      'panNo': panNo,
      'aadharCardNo': aadharCardNo,
      'gstnNo': gstnNo,
      'firmPanNo': firmPanNo,
      'annualTurnOver': annualTurnOver,
      'bankAccountNo': bankAccountNo,
      'bankIfscCode': bankIfscCode,
      'bankNameId': bankNameId,
      'beneficiaryName': beneficiaryName,
      'mdrType': mdrType,
      'termsCondition': termsCondition,
      'serviceAgreement': serviceAgreement,
      'merchantProductDetails':
          merchantProductDetails.map((detail) => detail.toJson()).toList(),
    };
  }
}

class MerchantProductDetails {
  String productName;
  int productId;
  String package;
  int packagetId;
  int quantity;

  MerchantProductDetails({
    required this.productName,
    required this.productId,
    required this.package,
    required this.packagetId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'packagetId': packagetId,
      'qty': quantity,
    };
  }
}

// void main() {
//   // Create an instance of MerchantData
//   MerchantData merchantData = MerchantData(
//     businessTypeId: 1,
//     panNo: "EYVPS3146G",
//     aadharCardNo: "215487546548",
//     gstnNo: "GASTK566556F",
//     firmPanNo: "HGFTGF656j",
//     annualTurnOver: "5 cr",
//     bankAccountNo: "656565657",
//     bankIfscCode: "ASADF65456454",
//     bankNameId: "BNKH67565k",
//     beneficiaryName: "AFFGHGVFFF",
//     mdrType: "AStnadarf",
//     termsCondition: true,
//     serviceAgreement: true,
//     merchantProductDetails: [
//       MerchantProductDetails(productId: "1", packagetId: "2", qty: 1),
//       MerchantProductDetails(productId: "2", packagetId: "3", qty: 4),
//       MerchantProductDetails(productId: "3", packagetId: "5", qty: 3),
//     ],
//   );

//   // Convert the instance to JSON
//   Map<String, dynamic> jsonData = merchantData.toJson();

//   // Print the JSON data
//   print(jsonEncode(jsonData));
// }
