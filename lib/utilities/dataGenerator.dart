import '../config/endpoints.dart';

List<Map<String, dynamic>> emvFields = [
  {"name": "Payload Format Indicator", "id": 00},
  {"name": "Point of Initiation Method ", "id": 01},
  {"name": "Merchant Account Information", "id": 26},
  {
    "name": "Merchant Account Information - Globally Unique Identifier",
    "id": 00
  },
  {"name": "Merchant Category Code", "id": 52},
  {"name": "Transaction Currency", "id": 53},
  {"name": "Transaction Amount", "id": 54},
  {"name": "Country Code", "id": 58},
  {"name": "Merchant Name", "id": 59},
  {"name": "Merchant Name", "id": 60},
  {"name": "Additional Data Field – Bill Number", "id": 01},
  {"name": "CRC", "id": 63},
];

Future getDataFromScanData(String? scanData) async {
  print(scanData);

  int? index54 = scanData?.indexOf("54"); // To get Amount
  int? index26 = scanData?.indexOf("26"); // To get account number
  int? index62 = scanData?.indexOf("62"); // To Get QrCodeId

  String? amount = "100.0";
  String accountInfo = "00043456";
  String? qrCodeId = "";
  String? merchantTag = "";

  if (index54 != -1) {
    // Check if "54" is found, and if there are at least two more characters in the string.
    // If so, extract the characters at index54 + 2 and index54 + 3.
    amount = scanData!.substring(index54! + 2, (index54! + 4));

    int numberOfDigits = int.parse(amount);

    amount = scanData!.substring(index54! + 4, (index54! + 4) + numberOfDigits);

    // print(amount);
  }

  if (index26 != -1) {
    // Check if "54" is found, and if there are at least two more characters in the string.
    // If so, extract the characters at index54 + 2 and index54 + 3.
    accountInfo = scanData!.substring(index26! + 2, (index26! + 4));

    int numberOfDigits = int.parse(accountInfo);

    accountInfo =
        scanData!.substring(index54! + 4, (index54! + 4) + numberOfDigits);

    // print(accountInfo);
  }

  if (index62 != -1) {
    String searchString = "62";
    String startDelimiter = '#';

    int? index62 = scanData?.indexOf(searchString);

    int? startIndex = scanData?.indexOf(startDelimiter, index62!);
    int? endIndex = scanData?.indexOf(startDelimiter, startIndex! + 1);

    if (startIndex != -1 && endIndex != -1 && startIndex != endIndex) {
      qrCodeId = scanData?.substring(startIndex! + 1, endIndex);
      print("Extracted qrcodeId: $qrCodeId");
    } else {
      print("No content found between delimiters after '62'.");
    }

    int indexOfTarget = index62! + 8;
    int? indexOfHash = scanData?.indexOf('#');

    if (indexOfHash != -1 && indexOfTarget < indexOfHash!) {
      merchantTag = scanData?.substring(indexOfTarget, indexOfHash);
      print("Extracted merchantTag: $merchantTag");
    } else {
      print("No '#' found or pattern doesn't match.");
    }
  }

  // print('amount$amount');

  var requestBody = {
    "payment": {
      "amount": amount,
      "currency": "AED",
      "reason": "Soccer shoes",
      "merchantId": EndPoints.merchantId,
      "terminalId": EndPoints.terminalId,
    }
  };

  return {
    "requestBody": requestBody,
    "accountInfo": accountInfo,
    "qrCodeId": qrCodeId,
    "merchantTag": merchantTag
  };
}
