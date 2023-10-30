class NearByLocationRequest {
  String? deviceType;
  double? latitude;
  double? longitude;

  NearByLocationRequest({this.deviceType, this.latitude, this.longitude});

  NearByLocationRequest.fromJson(Map<String, dynamic> json) {
    deviceType = json['deviceType'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceType'] = deviceType;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
