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

  int? index54 = scanData?.indexOf("54");
  int? index26 = scanData?.indexOf("26");

  String? amount = "100.0";
  String accountInfo="00043456";

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

    accountInfo = scanData!.substring(index54! + 4, (index54! + 4) + numberOfDigits);

    // print(accountInfo);
  }

  // print('amount$amount');


  var requestBody = {
    "payment": {
      "paymentId": "123456",
      "amount": amount,
      "currency": "AED",
      "reason": "Soccer shoes",
      "shopId": "10001",
      "cashDeskId": "10000001"
    }
  };

  return {"requestBody":requestBody,"accountInfo":accountInfo};

}
