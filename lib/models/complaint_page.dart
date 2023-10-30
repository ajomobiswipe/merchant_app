class ComplaintRequest {
  String? instId;
  String? userName;
  String? id;
  String? complaintMessage;
  bool? seenBy;
  String? custId;

  ComplaintRequest(
      {this.instId,
      this.userName,
      this.id,
      this.complaintMessage,
      this.seenBy,
      this.custId});

  ComplaintRequest.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    id = json['id'];
    complaintMessage = json['complaintMessage'];
    seenBy = json['seenBy'];
    custId = json['custId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['id'] = id;
    data['complaintMessage'] = complaintMessage;
    data['seenBy'] = seenBy;
    data['custId'] = custId;
    return data;
  }
}
