class Faq {
  String? responseType;
  ResponseValue? responseValue;

  Faq({this.responseType, this.responseValue});

  Faq.fromJson(Map<String, dynamic> json) {
    responseType = json['responseType'];
    responseValue = json['responseValue'] != null
        ? ResponseValue.fromJson(json['responseValue'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseType'] = responseType;
    if (responseValue != null) {
      data['responseValue'] = responseValue!.toJson();
    }
    return data;
  }
}

class ResponseValue {
  String? message;
  List<Data>? list;

  ResponseValue({this.message, this.list});

  ResponseValue.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['list'] != null) {
      list = <Data>[];
      json['list'].forEach((v) {
        list!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? category;
  List<Value>? value;

  Data({this.category, this.value});

  Data.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    if (json['value'] != null) {
      value = <Value>[];
      json['value'].forEach((v) {
        value!.add(Value.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    if (value != null) {
      data['value'] = value!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Value {
  String? category;
  String? queston;
  String? answer;
  String? isactive;

  Value({this.category, this.queston, this.answer, this.isactive});

  Value.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    queston = json['queston'];
    answer = json['answer'];
    isactive = json['isactive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['queston'] = queston;
    data['answer'] = answer;
    data['isactive'] = isactive;
    return data;
  }
}
