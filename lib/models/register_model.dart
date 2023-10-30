class RegisterRequestModel {
  String? notificationToken;
  String? instId;
  String? firstName;
  String? lastName;
  String? nickName;
  String? userName;
  String? password;
  String? confirmPassword;
  String? pin;
  String? confirmPin;
  String? mobileCountryCode;
  String? mobileNumber;
  String? emailId;
  String? dob;
  String? deviceType;
  String? deviceId;
  String? role;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  String? questionOne;
  String? answerOne;
  String? questionTwo;
  String? answerTwo;
  String? questionThree;
  String? answerThree;
  String? currencyId;
  String? postalCode;
  bool? acceptLicense;

  RegisterRequestModel(
      {this.instId,
      this.notificationToken,
      this.firstName,
      this.lastName,
      this.nickName,
      this.userName,
      this.password,
      this.confirmPassword,
      this.pin,
      this.confirmPin,
      this.mobileCountryCode,
      this.mobileNumber,
      this.emailId,
      this.dob,
      this.deviceType,
      this.deviceId,
      this.role,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.questionOne,
      this.answerOne,
      this.questionTwo,
      this.answerTwo,
      this.questionThree,
      this.answerThree,
      this.currencyId,
      this.postalCode,
      this.acceptLicense});

  RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    notificationToken = json['notificationToken'];
    instId = json['instId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    nickName = json['nickName'];
    userName = json['userName'];
    password = json['password'];
    confirmPassword = json['confirmPassword'];
    pin = json['pin'];
    confirmPin = json['confirmPin'];
    mobileCountryCode = json['mobileCountryCode'];
    mobileNumber = json['mobileNumber'];
    emailId = json['emailId'];
    dob = json['dob'];
    deviceType = json['deviceType'];
    deviceId = json['deviceId'];
    role = json['role'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipCode = json['zipCode'];
    questionOne = json['questionOne'];
    answerOne = json['answerOne'];
    questionTwo = json['questionTwo'];
    answerTwo = json['answerTwo'];
    questionThree = json['questionThree'];
    answerThree = json['answerThree'];
    currencyId = json['currencyId'];
    postalCode = json['postalCode'];
    acceptLicense = json['acceptLicense'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['notificationToken'] = notificationToken;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['nickName'] = nickName;
    data['userName'] = userName;
    data['password'] = password;
    data['confirmPassword'] = confirmPassword;
    data['pin'] = pin;
    data['confirmPin'] = confirmPin;
    data['mobileCountryCode'] = mobileCountryCode;
    data['mobileNumber'] = mobileNumber;
    data['emailId'] = emailId;
    data['dob'] = dob;
    data['deviceType'] = deviceType;
    data['deviceId'] = deviceId;
    data['role'] = role;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['zipCode'] = zipCode;
    data['questionOne'] = questionOne;
    data['answerOne'] = answerOne;
    data['questionTwo'] = questionTwo;
    data['answerTwo'] = answerTwo;
    data['questionThree'] = questionThree;
    data['answerThree'] = answerThree;
    data['currencyId'] = currencyId;
    data['postalCode'] = postalCode;
    data['acceptLicense'] = acceptLicense;
    return data;
  }
}

class MerchantRequestModel {
  String? notificationToken;
  String? instId;
  String? firstName;
  String? lastName;
  String? nickName;
  String? userName;
  String? password;
  String? confirmPassword;
  String? pin;
  String? confirmPin;
  String? mobileCountryCode;
  String? mobileNumber;
  String? emailId;
  String? dob;
  String? deviceType;
  String? deviceId;
  String? role;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  double? latitude;
  double? longitude;
  String? questionOne;
  String? answerOne;
  String? questionTwo;
  String? answerTwo;
  String? questionThree;
  String? answerThree;
  String? merchantName;
  String? currencyId;
  String? mcc;
  String? businessType;
  String? companyRegNumber;
  String? nationalId;
  String? nationalIdExpiry;
  String? merchantZipCode;
  String? tradeLicenseCode;
  String? tradeLicenseExpiry;
  String? kycType;
  bool? acceptLicense;

  MerchantRequestModel(
      {this.notificationToken,
      this.instId,
      this.firstName,
      this.lastName,
      this.nickName,
      this.userName,
      this.password,
      this.confirmPassword,
      this.pin,
      this.confirmPin,
      this.mobileCountryCode,
      this.mobileNumber,
      this.emailId,
      this.dob,
      this.deviceType,
      this.deviceId,
      this.role,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.latitude,
      this.longitude,
      this.questionOne,
      this.answerOne,
      this.questionTwo,
      this.answerTwo,
      this.questionThree,
      this.answerThree,
      this.merchantName,
      this.currencyId,
      this.mcc,
      this.businessType,
      this.companyRegNumber,
      this.nationalId,
      this.nationalIdExpiry,
      this.merchantZipCode,
      this.tradeLicenseCode,
      this.tradeLicenseExpiry,
      this.kycType,
      this.acceptLicense});

  MerchantRequestModel.fromJson(Map<String, dynamic> json) {
    notificationToken = json['notificationToken'];
    instId = json['instId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    nickName = json['nickName'];
    userName = json['userName'];
    password = json['password'];
    confirmPassword = json['confirmPassword'];
    pin = json['pin'];
    confirmPin = json['confirmPin'];
    mobileCountryCode = json['mobileCountryCode'];
    mobileNumber = json['mobileNumber'];
    emailId = json['emailId'];
    dob = json['dob'];
    deviceType = json['deviceType'];
    deviceId = json['deviceId'];
    role = json['role'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipCode = json['zipCode'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    questionOne = json['questionOne'];
    answerOne = json['answerOne'];
    questionTwo = json['questionTwo'];
    answerTwo = json['answerTwo'];
    questionThree = json['questionThree'];
    answerThree = json['answerThree'];
    merchantName = json['merchantName'];
    currencyId = json['currencyId'];
    mcc = json['mcc'];
    businessType = json['businessType'];
    companyRegNumber = json['companyRegNumber'];
    nationalId = json['nationalId'];
    nationalIdExpiry = json['nationalIdExpiry'];
    merchantZipCode = json['merchantZipCode'];
    tradeLicenseCode = json['tradeLicenseCode'];
    tradeLicenseExpiry = json['tradeLicenseExpiry'];
    kycType = json['kycType'];
    acceptLicense = json['acceptLicense'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notificationToken'] = notificationToken;
    data['instId'] = instId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['nickName'] = nickName;
    data['userName'] = userName;
    data['password'] = password;
    data['confirmPassword'] = confirmPassword;
    data['pin'] = pin;
    data['confirmPin'] = confirmPin;
    data['mobileCountryCode'] = mobileCountryCode;
    data['mobileNumber'] = mobileNumber;
    data['emailId'] = emailId;
    data['dob'] = dob;
    data['deviceType'] = deviceType;
    data['deviceId'] = deviceId;
    data['role'] = role;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['zipCode'] = zipCode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['questionOne'] = questionOne;
    data['answerOne'] = answerOne;
    data['questionTwo'] = questionTwo;
    data['answerTwo'] = answerTwo;
    data['questionThree'] = questionThree;
    data['answerThree'] = answerThree;
    data['merchantName'] = merchantName;
    data['currencyId'] = currencyId;
    data['mcc'] = mcc;
    data['businessType'] = businessType;
    data['companyRegNumber'] = companyRegNumber;
    data['nationalId'] = nationalId;
    data['nationalIdExpiry'] = nationalIdExpiry;
    data['merchantZipCode'] = merchantZipCode;
    data['tradeLicenseCode'] = tradeLicenseCode;
    data['tradeLicenseExpiry'] = tradeLicenseExpiry;
    data['kycType'] = kycType;
    data['acceptLicense'] = acceptLicense;
    return data;
  }
}
