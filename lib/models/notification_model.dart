class NotificationRequest {
  String? instId;
  String? custId;
  String? notificationId;

  NotificationRequest({this.instId, this.notificationId, this.custId});

  NotificationRequest.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    notificationId = json['notificationId'];
    custId = json['custId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['notificationId'] = notificationId;
    data['custId'] = custId;
    return data;
  }
}
