/* ===============================================================
| Project : SIFR
| Page    : KYC_SERVICE.DART
| Date    : 23-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/endpoints.dart';

class KycService {
  late String token;
  late String custId;

  /*
  * SERVICE NAME: uploadKyc
  * DESC: Upload Kyc Images
  * METHOD: POST
  * Params: KYC_back and KYC_front images
  * to pass token in Headers
  */
  uploadKyc(req) async {
    final request = http.MultipartRequest('POST',
        Uri.parse(EndPoints.baseApi9502 + EndPoints.addOrUpdateKYCInfo));
    final file = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_front.jpg', req['front']);
    final file2 = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_back.jpg', req['back']);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    custId = prefs.getString('custId')!;
    token = prefs.getString('token').toString();
    final header = {'Authorization': 'Bearer $token', 'Bearer': token};
    request.headers.addAll(header);
    request.files.add(file);
    request.files.add(file2);
    request.fields['custId'] = custId;
    request.fields['kycType'] = "E-KYC";
    request.fields['biometricData'] = "123";
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: uploadMerchantDocuments
  * DESC: Upload Merchant Document Images
  * METHOD: POST
  * Params: KYC,nationalIdDoc,tradeLicenseFile and canceledCheque Both Front and Back Images
  * to pass token in Headers
  */
  uploadMerchantDocuments(req) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    custId = prefs.getString('custId').toString();
    token = prefs.getString('token').toString();
    final header = {'Authorization': 'Bearer $token', 'Bearer': token};
    final request = http.MultipartRequest('POST',
        Uri.parse(EndPoints.baseApi9502 + EndPoints.addOrUpdateKYCInfo));
    request.headers.addAll(header);
    final kf = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_front.jpg', req['kycFront']);
    final kb = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_back.jpg', req['kycBack']);
    final nf = await http.MultipartFile.fromPath(
        'nationalIdDoc',
        filename: '_nationalIdFront.jpg',
        req['nationalIdFront']);
    final nb = await http.MultipartFile.fromPath(
        'nationalIdDoc',
        filename: '_nationalIdBack.jpg',
        req['nationalIdBack']);
    final tl = await http.MultipartFile.fromPath(
        'tradeLicenseFile',
        filename: '_tradeLicenseFile.jpg',
        req['tradeLicense']);
    if (req['cancelCheque'] != '') {
      final cc = await http.MultipartFile.fromPath(
          'canceledCheque',
          filename: '_cancelledCheque.jpg',
          req['cancelCheque']);
      request.files.add(cc);
    }
    request.files.add(kf);
    request.files.add(kb);
    request.files.add(nf);
    request.files.add(nb);
    request.files.add(tl);
    request.fields['custId'] = custId;
    request.fields['kycType'] = "E-KYC";
    request.fields['biometricData'] = "123";
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: emiratesUpload
  * DESC: Upload Merchant emirates Images
  * METHOD: POST
  * Params: KYC and nationalIdDoc Both Front and Back Images
  * to pass token in Headers
  */
  emiratesUpload(req) async {
    final request = http.MultipartRequest('POST',
        Uri.parse(EndPoints.baseApi9502 + EndPoints.addOrUpdateKYCInfo));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    custId = prefs.getString('custId')!;
    token = prefs.getString('token').toString();
    final header = {'Authorization': 'Bearer $token', 'Bearer': token};
    request.headers.addAll(header);

    final file = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_front.jpg', req['kycFront']);
    final file2 = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_back.jpg', req['kycBack']);
    final nf = await http.MultipartFile.fromPath(
        'nationalIdDoc', filename: '_national_F.jpg', req['nationalIdFront']);
    final nb = await http.MultipartFile.fromPath(
        'nationalIdDoc', filename: '_national_B.jpg', req['nationalIdBack']);
    request.files.add(file);
    request.files.add(file2);
    request.files.add(nf);
    request.files.add(nb);
    request.fields['custId'] = custId;
    request.fields['kycType'] = "E-KYC";
    request.fields['biometricData'] = "123";
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: tradeUpload
  * DESC: Upload Merchant trade Images
  * METHOD: POST
  * Params: KYC and tradeLicense Both Front and Back Images
  * to pass token in Headers
  */
  tradeUpload(req) async {
    final request = http.MultipartRequest('POST',
        Uri.parse(EndPoints.baseApi9502 + EndPoints.addOrUpdateKYCInfo));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    custId = prefs.getString('custId')!;
    token = prefs.getString('token').toString();
    final header = {'Authorization': 'Bearer $token', 'Bearer': token};
    request.headers.addAll(header);

    final file = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_front.jpg', req['kycFront']);
    final file2 = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_back.jpg', req['kycBack']);
    final tl = await http.MultipartFile.fromPath(
        'tradeLicenseFile', filename: '_tradeLicense.jpg', req['tradeLicense']);
    request.files.add(file);
    request.files.add(file2);
    request.files.add(tl);
    request.fields['custId'] = custId;
    request.fields['kycType'] = "E-KYC";
    request.fields['biometricData'] = "123";
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  /*
  * SERVICE NAME: cancelCheque
  * DESC: Upload Merchant cancelCheque Images
  * METHOD: POST
  * Params: KYC and canceledCheque Both Front and Back Images
  * to pass token in Headers
  */
  cancelCheque(req) async {
    final request = http.MultipartRequest('POST',
        Uri.parse(EndPoints.baseApi9502 + EndPoints.addOrUpdateKYCInfo));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    custId = prefs.getString('custId')!;
    token = prefs.getString('token').toString();
    final header = {'Authorization': 'Bearer $token', 'Bearer': token};
    request.headers.addAll(header);

    final file = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_front.jpg', req['kycFront']);
    final file2 = await http.MultipartFile.fromPath(
        'file', filename: '_KYC_back.jpg', req['kycBack']);
    final tl = await http.MultipartFile.fromPath(
        'canceledCheque',
        filename: '_canceledCheque.jpg',
        req['canceledCheque']);
    request.files.add(file);
    request.files.add(file2);
    request.files.add(tl);
    request.fields['custId'] = custId;
    request.fields['kycType'] = "E-KYC";
    request.fields['biometricData'] = "123";
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
