class GetSecurityQuestions {
  String? id;
  String? createdAt;
  String? name;
  String? avatar;

  GetSecurityQuestions({this.id, this.createdAt, this.name, this.avatar});

  GetSecurityQuestions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    name = json['name'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['name'] = name;
    data['avatar'] = avatar;
    return data;
  }

  static List<GetSecurityQuestions>? fromJsonList(List list) {
    // if (list == null) return null;
    return list.map((item) => GetSecurityQuestions.fromJson(item)).toList();
  }
}

class SecurityQuestionResponse {
  String? responseCode;
  String? responseMessage;
  String? questionOne;
  String? questionTwo;
  String? questionThree;
  String? timestamp;
  String? message;
  String? details;

  SecurityQuestionResponse(
      {this.responseCode,
      this.responseMessage,
      this.questionOne,
      this.questionTwo,
      this.questionThree,
      this.message,
      this.timestamp,
      this.details});

  SecurityQuestionResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    questionOne = json['questionOne'];
    questionTwo = json['questionTwo'];
    questionThree = json['questionThree'];
    details = json['details'];
    message = json['message'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['responseMessage'] = responseMessage;
    data['questionOne'] = questionOne;
    data['questionTwo'] = questionTwo;
    data['questionThree'] = questionThree;
    data['details'] = details;
    data['timestamp'] = timestamp;
    data['message'] = message;
    return data;
  }
}

class SecurityQuestionVerification {
  String? instId;
  String? userName;
  String? questionOne;
  String? answerOne;
  String? questionTwo;
  String? answerTwo;
  String? questionThree;
  String? answerThree;

  SecurityQuestionVerification(
      {this.instId,
      this.userName,
      this.questionOne,
      this.questionTwo,
      this.answerOne,
      this.answerTwo,
      this.answerThree,
      this.questionThree});

  SecurityQuestionVerification.fromJson(Map<String, dynamic> json) {
    instId = json['instId'];
    userName = json['userName'];
    questionOne = json['questionOne'];
    questionTwo = json['questionTwo'];
    questionThree = json['questionThree'];
    answerOne = json['answerOne'];
    answerTwo = json['answerTwo'];
    answerThree = json['answerThree'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instId'] = instId;
    data['userName'] = userName;
    data['questionOne'] = questionOne;
    data['questionTwo'] = questionTwo;
    data['questionThree'] = questionThree;
    data['answerOne'] = answerOne;
    data['answerTwo'] = answerTwo;
    data['answerThree'] = answerThree;
    return data;
  }
}
