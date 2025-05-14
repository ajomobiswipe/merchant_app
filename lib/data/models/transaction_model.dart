// To parse this JSON data, do
//
//     final transaction = transactionFromJson(jsonString);

import 'dart:convert';

Transaction transactionFromJson(String str) =>
    Transaction.fromJson(json.decode(str));

String transactionToJson(Transaction data) => json.encode(data.toJson());

class Transaction {
  final List<TransactionElement>? transactions;

  Transaction({
    this.transactions,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        transactions: json["transactions"] == null
            ? []
            : List<TransactionElement>.from(json["transactions"]!
                .map((x) => TransactionElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "transactions": transactions == null
            ? []
            : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class TransactionElement {
  final String? transactionId;
  final String? merchantId;
  final String? terminalId;
  final String? batchNumber;
  final String? invoiceNumber;
  final DateTime? timestamp;
  final String? status;
  final String? transactionType;
  final String? entryMode;
  final String? settlementStatus;
  final Amount? amount;
  final PaymentMethod? paymentMethod;
  final Authorization? authorization;
  final Fees? fees;
  final Total? total;
  final Settlement? settlement;
  final String? failureReason;
  final String? originalTransactionId;
  final String? reason;

  TransactionElement({
    this.transactionId,
    this.merchantId,
    this.terminalId,
    this.batchNumber,
    this.invoiceNumber,
    this.timestamp,
    this.status,
    this.transactionType,
    this.entryMode,
    this.settlementStatus,
    this.amount,
    this.paymentMethod,
    this.authorization,
    this.fees,
    this.total,
    this.settlement,
    this.failureReason,
    this.originalTransactionId,
    this.reason,
  });

  factory TransactionElement.fromJson(Map<String, dynamic> json) =>
      TransactionElement(
        transactionId: json["transactionId"],
        merchantId: json["merchantId"],
        terminalId: json["terminalId"],
        batchNumber: json["batchNumber"],
        invoiceNumber: json["invoiceNumber"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        status: json["status"],
        transactionType: json["transactionType"],
        entryMode: json["entryMode"],
        settlementStatus: json["settlementStatus"],
        amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
        paymentMethod: json["paymentMethod"] == null
            ? null
            : PaymentMethod.fromJson(json["paymentMethod"]),
        authorization: json["authorization"] == null
            ? null
            : Authorization.fromJson(json["authorization"]),
        fees: json["fees"] == null ? null : Fees.fromJson(json["fees"]),
        total: json["total"] == null ? null : Total.fromJson(json["total"]),
        settlement: json["settlement"] == null
            ? null
            : Settlement.fromJson(json["settlement"]),
        failureReason: json["failureReason"],
        originalTransactionId: json["originalTransactionId"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "transactionId": transactionId,
        "merchantId": merchantId,
        "terminalId": terminalId,
        "batchNumber": batchNumber,
        "invoiceNumber": invoiceNumber,
        "timestamp": timestamp?.toIso8601String(),
        "status": status,
        "transactionType": transactionType,
        "entryMode": entryMode,
        "settlementStatus": settlementStatus,
        "amount": amount?.toJson(),
        "paymentMethod": paymentMethod?.toJson(),
        "authorization": authorization?.toJson(),
        "fees": fees?.toJson(),
        "total": total?.toJson(),
        "settlement": settlement?.toJson(),
        "failureReason": failureReason,
        "originalTransactionId": originalTransactionId,
        "reason": reason,
      };
}

class Amount {
  final Currency? currency;
  final double? value;

  Amount({
    this.currency,
    this.value,
  });

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
        currency: currencyValues.map[json["currency"]]!,
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "currency": currencyValues.reverse[currency],
        "value": value,
      };
}

enum Currency { INR }

final currencyValues = EnumValues({"INR": Currency.INR});

class Authorization {
  final String? authCode;
  final String? transactionReference;
  final String? gateway;
  final String? rrn;
  final String? stan;
  final String? mode;

  Authorization({
    this.authCode,
    this.transactionReference,
    this.gateway,
    this.rrn,
    this.stan,
    this.mode,
  });

  factory Authorization.fromJson(Map<String, dynamic> json) => Authorization(
        authCode: json["authCode"],
        transactionReference: json["transactionReference"],
        gateway: json["gateway"],
        rrn: json["rrn"],
        stan: json["stan"],
        mode: json["mode"],
      );

  Map<String, dynamic> toJson() => {
        "authCode": authCode,
        "transactionReference": transactionReference,
        "gateway": gateway,
        "rrn": rrn,
        "stan": stan,
        "mode": mode,
      };
}

class Fees {
  final Amount? serviceFee;
  final Amount? processingFee;
  final Amount? networkFee;
  final Amount? chargebackFee;

  Fees({
    this.serviceFee,
    this.processingFee,
    this.networkFee,
    this.chargebackFee,
  });

  factory Fees.fromJson(Map<String, dynamic> json) => Fees(
        serviceFee: json["serviceFee"] == null
            ? null
            : Amount.fromJson(json["serviceFee"]),
        processingFee: json["processingFee"] == null
            ? null
            : Amount.fromJson(json["processingFee"]),
        networkFee: json["networkFee"] == null
            ? null
            : Amount.fromJson(json["networkFee"]),
        chargebackFee: json["chargebackFee"] == null
            ? null
            : Amount.fromJson(json["chargebackFee"]),
      );

  Map<String, dynamic> toJson() => {
        "serviceFee": serviceFee?.toJson(),
        "processingFee": processingFee?.toJson(),
        "networkFee": networkFee?.toJson(),
        "chargebackFee": chargebackFee?.toJson(),
      };
}

class PaymentMethod {
  final String? type;
  final Card? card;
  final String? upiId;

  PaymentMethod({
    this.type,
    this.card,
    this.upiId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        type: json["type"],
        card: json["card"] == null ? null : Card.fromJson(json["card"]),
        upiId: json["upiId"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "card": card?.toJson(),
        "upiId": upiId,
      };
}

class Card {
  final String? brand;
  final String? last4;
  final String? expiryDate;
  final String? issuerBank;
  final String? cardType;
  final String? cardholderName;

  Card({
    this.brand,
    this.last4,
    this.expiryDate,
    this.issuerBank,
    this.cardType,
    this.cardholderName,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        brand: json["brand"],
        last4: json["last4"],
        expiryDate: json["expiryDate"],
        issuerBank: json["issuerBank"],
        cardType: json["cardType"],
        cardholderName: json["cardholderName"],
      );

  Map<String, dynamic> toJson() => {
        "brand": brand,
        "last4": last4,
        "expiryDate": expiryDate,
        "issuerBank": issuerBank,
        "cardType": cardType,
        "cardholderName": cardholderName,
      };
}

class Settlement {
  final String? batchId;
  final DateTime? settlementDate;
  final String? processedBy;
  final Amount? settlementAmount;

  Settlement({
    this.batchId,
    this.settlementDate,
    this.processedBy,
    this.settlementAmount,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
        batchId: json["batchId"],
        settlementDate: json["settlementDate"] == null
            ? null
            : DateTime.parse(json["settlementDate"]),
        processedBy: json["processedBy"],
        settlementAmount: json["settlementAmount"] == null
            ? null
            : Amount.fromJson(json["settlementAmount"]),
      );

  Map<String, dynamic> toJson() => {
        "batchId": batchId,
        "settlementDate":
            "${settlementDate!.year.toString().padLeft(4, '0')}-${settlementDate!.month.toString().padLeft(2, '0')}-${settlementDate!.day.toString().padLeft(2, '0')}",
        "processedBy": processedBy,
        "settlementAmount": settlementAmount?.toJson(),
      };
}

class Total {
  final Amount? subtotal;
  final Amount? fees;
  final Amount? grandTotal;

  Total({
    this.subtotal,
    this.fees,
    this.grandTotal,
  });

  factory Total.fromJson(Map<String, dynamic> json) => Total(
        subtotal:
            json["subtotal"] == null ? null : Amount.fromJson(json["subtotal"]),
        fees: json["fees"] == null ? null : Amount.fromJson(json["fees"]),
        grandTotal: json["grandTotal"] == null
            ? null
            : Amount.fromJson(json["grandTotal"]),
      );

  Map<String, dynamic> toJson() => {
        "subtotal": subtotal?.toJson(),
        "fees": fees?.toJson(),
        "grandTotal": grandTotal?.toJson(),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
