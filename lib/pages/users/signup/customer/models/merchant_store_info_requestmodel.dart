// To parse this JSON data, do
//
//     final merchantStoreInfoRequestmodel = merchantStoreInfoRequestmodelFromJson(jsonString);

import 'dart:convert';

MerchantStoreInfoRequestmodel merchantStoreInfoRequestmodelFromJson(
        String str) =>
    MerchantStoreInfoRequestmodel.fromJson(json.decode(str));

String merchantStoreInfoRequestmodelToJson(
        MerchantStoreInfoRequestmodel data) =>
    json.encode(data.toJson());

class MerchantStoreInfoRequestmodel {
  String? currentCountry;
  String? currentCity;
  String? currentState;
  String? currentZipCode;
  String? currentAddress;
  double? latitude;
  double? longitude;
  bool isBusinessAddSameAsStore;

  MerchantStoreInfoRequestmodel(
      {this.currentCountry,
      this.currentCity,
      this.currentState,
      this.currentZipCode,
      this.currentAddress,
      this.latitude,
      this.longitude,
      this.isBusinessAddSameAsStore = false});

  factory MerchantStoreInfoRequestmodel.fromJson(Map<String, dynamic> json) =>
      MerchantStoreInfoRequestmodel(
        currentCountry: json["currentCountry"],
        currentCity: json["currentCity"],
        currentState: json["currentState"],
        currentZipCode: json["currentZipCode"],
        currentAddress: json["currentAddress"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "currentCountry": currentCountry,
        "currentCity": currentCity,
        "currentState": currentState,
        "currentZipCode": currentZipCode,
        "currentAddress": currentAddress,
        "latitude": latitude,
        "longitude": longitude,
        "isAddressSame": isBusinessAddSameAsStore,
      };
}
