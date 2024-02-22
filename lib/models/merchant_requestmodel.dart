class MerchantRegPersonalReqModel {
  String? firstName;
  String? lastName;
  String? dob;
  int? poiType;
  String? poiNumber;
  String? poiExpiryDate;
  int? poaType;
  String? poaNumber;
  String? poaExpiryDate;
  String? currentAddress;
  int? currentCountry;
  String? permanentState;
  int? currentState;
  String? currentNationality;
  String? currentMobileNo;
  String? currentAltMobNo;
  String? permanentAddress;
  int? permanentCountry;
  String? permanentZipCode;
  String? currentZipCode;

  MerchantRegPersonalReqModel({
    this.firstName,
    this.lastName,
    this.dob,
    this.poiType,
    this.poiNumber,
    this.poiExpiryDate,
    this.poaType,
    this.poaNumber,
    this.poaExpiryDate,
    this.currentAddress,
    this.currentCountry,
    this.permanentState,
    this.currentState,
    this.currentNationality,
    this.currentMobileNo,
    this.currentAltMobNo,
    this.permanentAddress,
    this.permanentCountry,
    this.permanentZipCode,
    this.currentZipCode,
  });

  MerchantRegPersonalReqModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    dob = json['dob'];
    poiType = json['poiType'];
    poiNumber = json['poiNumber'];
    poiExpiryDate = json['poiExpiryDate'];
    poaType = json['poaType'];
    poaNumber = json['poaNumber'];
    poaExpiryDate = json['poaExpiryDate'];
    currentAddress = json['currentAddress'];
    currentCountry = json['currentCountry'];
    permanentState = json['permanentState'];
    currentState = json['currentState'];
    currentNationality = json['currentNationality'];
    currentMobileNo = json['currentMobileNo'];
    currentAltMobNo = json['currentAltMobNo'];
    permanentAddress = json['permanentAddress'];
    permanentCountry = json['permanentCountry'];
    permanentZipCode = json['permanentZipCode'];
    currentZipCode = json['currentZipCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['dob'] = dob;
    data['poiType'] = poiType;
    data['poiNumber'] = poiNumber;
    data['poiExpiryDate'] = poiExpiryDate;
    data['poaType'] = poaType;
    data['poaNumber'] = poaNumber;
    data['poaExpiryDate'] = poaExpiryDate;
    data['currentAddress'] = currentAddress;
    data['currentCountry'] = currentCountry;
    data['permanentState'] = permanentState;
    data['currentState'] = currentState;
    data['currentNationality'] = currentNationality;
    data['currentMobileNo'] = currentMobileNo;
    data['currentAltMobNo'] = currentAltMobNo;
    data['permanentAddress'] = permanentAddress;
    data['permanentCountry'] = permanentCountry;
    data['permanentZipCode'] = permanentZipCode;
    data['currentZipCode'] = currentZipCode;
    return data;
  }
}

class MerchantCompanyDetailsReqModel {
  String? acquirerId;
  String? merchantId;
  String? merchantName;
  String? merchantAddress;
  String? merchantAddr2;
  String? description;
  int? cityCode;
  int? countryId;
  int? currency;
  String? mobileNo;
  String? emailId;
  bool? status;
  String? zipCode;
  int? mccTypeCode;
  String? merchantLogoImage;
  String? commercialName;
  String? tradeLicenseNumber;
  String? tradeLicenseExpiryDate;
  String? ownership;
  String? shareholderPercent;
  int? relationshipManagerId;
  bool? vatApplicable;
  String? vatRegistrationNumber;
  String? vatValue;
  String? maxAuthAmount;
  String? maxTerminalCount;
  bool? isDccSupported;
  bool? tipsAllowed;
  bool? holdFullPaymentAmount;
  int? geofenceRadius;

  MerchantCompanyDetailsReqModel({
    this.acquirerId,
    this.merchantId,
    this.merchantName,
    this.merchantAddress,
    this.merchantAddr2,
    this.description,
    this.cityCode,
    this.countryId,
    this.currency,
    this.mobileNo,
    this.emailId,
    this.status,
    this.zipCode,
    this.mccTypeCode,
    this.merchantLogoImage,
    this.commercialName,
    this.tradeLicenseNumber,
    this.tradeLicenseExpiryDate,
    this.ownership,
    this.shareholderPercent,
    this.relationshipManagerId,
    this.vatApplicable,
    this.vatRegistrationNumber,
    this.vatValue,
    this.maxAuthAmount,
    this.maxTerminalCount,
    this.isDccSupported,
    this.tipsAllowed,
    this.holdFullPaymentAmount,
    this.geofenceRadius,
  });

  MerchantCompanyDetailsReqModel.fromJson(Map<String, dynamic> json) {
    acquirerId = json['acquirerId'];
    merchantId = json['merchantId'];
    merchantName = json['merchantName'];
    merchantAddress = json['merchantAddress'];
    merchantAddr2 = json['merchantAddr2'];
    description = json['description'];
    cityCode = json['cityCode'];
    countryId = json['countryId'];
    currency = json['currency'];
    mobileNo = json['mobileNo'];
    emailId = json['emailId'];
    status = json['status'];
    zipCode = json['zipCode'];
    mccTypeCode = json['mccTypeCode'];
    merchantLogoImage = json['merchantLogoImage'];
    commercialName = json['commercialName'];
    tradeLicenseNumber = json['tradeLicenseNumber'];
    tradeLicenseExpiryDate = json['tradeLicenseExpiryDate'];
    ownership = json['ownership'];
    shareholderPercent = json['shareholderPercent'];
    relationshipManagerId = json['relationshipManagerId'];
    vatApplicable = json['vatApplicable'];
    vatRegistrationNumber = json['vatRegistrationNumber'];
    vatValue = json['vatValue'];
    maxAuthAmount = json['maxAuthAmount'];
    maxTerminalCount = json['maxTerminalCount'];
    isDccSupported = json['isDccSupported'];
    tipsAllowed = json['tipsAllowed'];
    holdFullPaymentAmount = json['holdFullPaymentAmount'];
    geofenceRadius = json['geofenceRadius'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['acquirerId'] = acquirerId;
    data['merchantId'] = merchantId;
    data['merchantName'] = merchantName;
    data['merchantAddress'] = merchantAddress;
    data['merchantAddr2'] = merchantAddr2;
    data['description'] = description;
    data['cityCode'] = cityCode;
    data['countryId'] = countryId;
    data['currency'] = currency;
    data['mobileNo'] = mobileNo;
    data['emailId'] = emailId;
    data['status'] = status;
    data['zipCode'] = zipCode;
    data['mccTypeCode'] = mccTypeCode;
    data['merchantLogoImage'] = merchantLogoImage;
    data['commercialName'] = commercialName;
    data['tradeLicenseNumber'] = tradeLicenseNumber;
    data['tradeLicenseExpiryDate'] = tradeLicenseExpiryDate;
    data['ownership'] = ownership;
    data['shareholderPercent'] = shareholderPercent;
    data['relationshipManagerId'] = relationshipManagerId;
    data['vatApplicable'] = vatApplicable;
    data['vatRegistrationNumber'] = vatRegistrationNumber;
    data['vatValue'] = vatValue;
    data['maxAuthAmount'] = maxAuthAmount;
    data['maxTerminalCount'] = maxTerminalCount;
    data['isDccSupported'] = isDccSupported;
    data['tipsAllowed'] = tipsAllowed;
    data['holdFullPaymentAmount'] = holdFullPaymentAmount;
    data['geofenceRadius'] = geofenceRadius;
    return data;
  }
}
