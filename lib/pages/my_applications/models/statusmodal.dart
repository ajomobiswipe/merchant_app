// To parse this JSON data, do
//
//     final applicationStatus = applicationStatusFromJson(jsonString);

import 'dart:convert';

ApplicationStatus applicationStatusFromJson(String str) =>
    ApplicationStatus.fromJson(json.decode(str));

String applicationStatusToJson(ApplicationStatus data) =>
    json.encode(data.toJson());

class ApplicationStatus {
  String? errorMessage;
  int? statusCode;
  int? amountToPay;
  bool? kycApproved;
  bool? payment;
  bool? eNach;
  bool? midtidGenerated;
  bool? allDevicesOnboarded;
  bool? live;

  List<Device>? devices;
  dynamic map;
  dynamic merchantProductDetailsResponse;

  ApplicationStatus(
      {this.errorMessage,
      this.statusCode,
      this.amountToPay,
      this.kycApproved = false,
      this.payment = false,
      this.eNach = false,
      this.midtidGenerated = false,
      this.allDevicesOnboarded = false,
      this.live = true,
      this.devices,
      this.map,
      this.merchantProductDetailsResponse});

  factory ApplicationStatus.fromJson(Map<String, dynamic> json) =>
      ApplicationStatus(
        errorMessage: json["errorMessage"],
        statusCode: json["statusCode"],
        amountToPay: json["amountToPay"],
        kycApproved: json["kycApproved"] ?? false,
        payment: json["payment"] ?? false,
        eNach: json["eNACH"] ?? false,
        midtidGenerated: json["MIDTIDGenerated"] ?? false,
        allDevicesOnboarded: json["allDevicesOnboarded"] ?? false,
        live: json["live"] ?? true,
        devices: json["devices"] == null
            ? []
            : List<Device>.from(
                json["devices"]!.map((x) => Device.fromJson(x))),
        map: json["map"],
      );

  Map<String, dynamic> toJson() => {
        "errorMessage": errorMessage,
        "statusCode": statusCode,
        "amountToPay": amountToPay,
        "kycApproved": kycApproved,
        "payment": payment,
        "eNACH": eNach,
        "MIDTIDGenerated": midtidGenerated,
        "allDevicesOnboarded": allDevicesOnboarded,
        "live": live,
        "devices": devices == null
            ? []
            : List<dynamic>.from(devices!.map((x) => x.toJson())),
        "map": map,
      };
}

class Device {
  String? productId;
  String? productName;
  String? merchantId;
  String? packageId;
  String? package;
  int? guid;
  int? quantity;
  int? pendingQty;
  int? price;
  bool? deploymentStatus;

  Device({
    this.productId,
    this.productName,
    this.packageId,
    this.package,
    this.quantity,
    this.pendingQty,
    this.price,
    this.merchantId,
    this.guid,
    this.deploymentStatus,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        productId: json["productId"],
        productName: json["productName"],
        packageId: json["packageId"],
        package: json["package"],
        quantity: json["quantity"],
        price: json["price"],
        deploymentStatus: json["deploymentStatus"],
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "productName": productName,
        "packageId": packageId,
        "package": package,
        "quantity": quantity,
        "price": price,
        "deploymentStatus": deploymentStatus,
      };
}
