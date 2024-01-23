class SalesTeamLoginModel {
  String? userName;
  String? password;
  String? deviceType;

  // Constructor
  SalesTeamLoginModel({
    this.userName,
    this.password,
    this.deviceType,
  });

  // Factory method to create an instance from JSON data
  factory SalesTeamLoginModel.fromJson(Map<String, dynamic> json) {
    return SalesTeamLoginModel(
      userName: json['userName'] as String,
      password: json['password'] as String,
      deviceType: json['deviceType'] as String,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'deviceType': "WEB",
    };
  }
}
