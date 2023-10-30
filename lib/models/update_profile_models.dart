class UpdatePersonalInfoModel {
  String? firstName;
  String? lastName;
  String? nickName;
  String? address;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  String? merchZipCode;

  UpdatePersonalInfoModel({
    this.nickName,
    this.firstName,
    this.lastName,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.merchZipCode,
  });

  UpdatePersonalInfoModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    nickName = json['nickName'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postalCode'];
    merchZipCode = json['merchZipCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nickName'] = nickName;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['postalCode'] = postalCode;
    data['merchZipCode'] = merchZipCode;
    return data;
  }
}

class MerchantUpdate {
  String? firstName;
  String? lastName;
  String? merchName;
  double? latitude;
  double? longitude;
  String? currencyId;
  String? merchantZipCode;
  String? mcc;
  String? companyRegNumber;
  String? businessType;
  String? tradeLicenseExpiry;
  String? tradeLicenseCode;
  String? nationalId;
  String? nationalIdExpiry;

  MerchantUpdate(
      {this.firstName,
      this.lastName,
      this.merchName,
      this.latitude,
      this.longitude,
      this.currencyId,
      this.merchantZipCode,
      this.mcc,
      this.companyRegNumber,
      this.businessType,
      this.tradeLicenseExpiry,
      this.tradeLicenseCode,
      this.nationalId,
      this.nationalIdExpiry});

  MerchantUpdate.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    merchName = json['merchName'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    currencyId = json['currencyId'];
    merchantZipCode = json['merchantZipCode'];
    mcc = json['mcc'];
    companyRegNumber = json['companyRegNumber'];
    businessType = json['businessType'];
    tradeLicenseExpiry = json['tradeLicenseExpiry'];
    tradeLicenseCode = json['tradeLicenseCode'];
    nationalId = json['nationalId'];
    nationalIdExpiry = json['nationalIdExpiry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['merchName'] = merchName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['currencyId'] = currencyId;
    data['merchantZipCode'] = merchantZipCode;
    data['mcc'] = mcc;
    data['companyRegNumber'] = companyRegNumber;
    data['businessType'] = businessType;
    data['tradeLicenseExpiry'] = tradeLicenseExpiry;
    data['tradeLicenseCode'] = tradeLicenseCode;
    data['nationalId'] = nationalId;
    data['nationalIdExpiry'] = nationalIdExpiry;
    return data;
  }
}
