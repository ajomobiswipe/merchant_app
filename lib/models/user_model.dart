class UpdateDetails {
  String? mobileNumber;
  String? emailId;
  String? firstName;
  String? lastName;
  String? fatherName;
  String? motherName;
  String? address;
  String? city;
  String? district;
  String? state;
  String? country;
  String? postalCode;
  String? dob;
  String? nickName;

  UpdateDetails(
      {this.mobileNumber,
      this.emailId,
      this.firstName,
      this.lastName,
      this.fatherName,
      this.motherName,
      this.address,
      this.city,
      this.district,
      this.state,
      this.country,
      this.postalCode,
      this.nickName,
      this.dob});

  UpdateDetails.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobileNumber'];
    emailId = json['emailId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    address = json['address'];
    city = json['city'];
    district = json['district'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postalCode'];
    dob = json['dob'];
    nickName = json['nickName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobileNumber'] = mobileNumber;
    data['emailId'] = emailId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['fatherName'] = fatherName;
    data['motherName'] = motherName;
    data['address'] = address;
    data['city'] = city;
    data['district'] = district;
    data['state'] = state;
    data['country'] = country;
    data['postalCode'] = postalCode;
    data['dob'] = dob;
    data['nickName'] = nickName;
    return data;
  }
}
