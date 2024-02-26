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
  bool? gstnVerifyStatus;
  bool? firmPanNumberVerifyStatus;
  List<MechantKycDocument>? mechantKycDocuments;

  BusinessIdProofRequestmodel({
    this.gstnNo,
    this.firmPanNo,
    this.gstnVerifyStatus,
    this.firmPanNumberVerifyStatus,
    this.mechantKycDocuments,
  });

  factory BusinessIdProofRequestmodel.fromJson(Map<String, dynamic> json) =>
      BusinessIdProofRequestmodel(
        gstnNo: json["gstnNo"],
        firmPanNo: json["firmPanNo"],
        gstnVerifyStatus: json["gstnVerifyStatus"],
        firmPanNumberVerifyStatus: json["firmPanNumberVerifyStatus"],
        mechantKycDocuments: json["mechantKycDocuments"] == null
            ? []
            : List<MechantKycDocument>.from(json["mechantKycDocuments"]!
                .map((x) => MechantKycDocument.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "gstnNo": gstnNo,
        "firmPanNo": firmPanNo,
        "gstnVerifyStatus": gstnVerifyStatus,
        "firmPanNumberVerifyStatus": firmPanNumberVerifyStatus,
        "mechantKycDocuments": mechantKycDocuments == null
            ? []
            : List<dynamic>.from(mechantKycDocuments!
                .map((x) => x.toJson(mechantKycDocuments!.indexOf(x)))),
      };
}

class MechantKycDocument {
  int? fileId;
  int? documentTypeId;
  String? fileName;
  String? documentExpiry;
  String? documentTypeName;
  String? fileFullPath;

  MechantKycDocument({
    this.fileId,
    this.documentTypeId,
    this.fileName,
    this.documentExpiry,
    this.documentTypeName,
    this.fileFullPath,
  });

  factory MechantKycDocument.fromJson(Map<String, dynamic> json) =>
      MechantKycDocument(
          fileId: json["fileId"],
          documentTypeId: json["documentTypeId"],
          fileName: json["fileName"],
          documentExpiry: json["documentExpiry"]);

  Map<String, dynamic> toJson(fileIndexId) => {
        "fileId": fileIndexId,
        "documentTypeId": documentTypeId,
        "fileName": fileName,
        "documentExpiry": documentExpiry,
      };
}
