/* ===============================================================
| Project : SIFR
| Page    : CONNECTION.DART
| Date    : 23-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/app/alert_service.dart';

import '../main.dart';

class Connection {
  // Header type
  final header = {'Content-Type': 'application/json'};
  static const int timeOutDuration = 35; //Api call time out duration
  AlertService alertService = AlertService();
  BoxStorage boxStorage = BoxStorage();

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/ca/certificate.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    if (kDebugMode) {
      print(sc);
    }
    return sc;
  }

  /*
  * SERVICE NAME: postWithOutToken
  * DESC: Global POST Method Without Token
  * METHOD: POST
  * Params: url and requestData
  */
  postWithOutToken(url, requestData) async {
    // var response = await http.post(Uri.parse(url),
    //     body: jsonEncode(requestData), headers: header);
    // return response;

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var response = await ioClient.post(Uri.parse(url),
        body: jsonEncode(requestData), headers: header);
    print(response.body);
    return response;
  }

  /*
  * SERVICE NAME: getWithOutToken
  * DESC: Global GET Method Without Token
  * METHOD: GET
  * Params: url
  */
  getWithOutToken(url) async {
    // return await http.get(Uri.parse(url));
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var response = await ioClient.get(Uri.parse(url));
    return response;
  }

  /*
  * SERVICE NAME: get
  * DESC: Global GET Method With Token
  * METHOD: GET
  * Params: url
  */
  get(String url) async {
    String token = boxStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Bearer': token,
      'Content-Type': 'application/json'
    };

    // var res = await http.get(Uri.parse(url), headers: headers);

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var res = await ioClient.get(Uri.parse(url), headers: headers);

    if (res.statusCode == 401) {
      alertService.errorToast(Constants.unauthorized);
      navigatorKey.currentState?.pushReplacementNamed('login');
      clearStorage();
    } else {
      return res;
    }
  }

  /*
  * SERVICE NAME: post
  * DESC: Global POST Method With Token
  * METHOD: POST
  * Params: url and requestData
  */
  post(url, requestData) async {
    String token = boxStorage.getToken();
    final header = {
      'Authorization': 'Bearer $token',
      'Bearer': token,
      'Content-Type': 'application/json'
    };

    print(token);
    // var res = await http.post(Uri.parse(url),
    //     body: jsonEncode(requestData), headers: header);

    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var res = await ioClient.post(Uri.parse(url),
        body: jsonEncode(requestData), headers: header);
    print(res.body);

    if (res.statusCode == 401) {
      alertService.errorToast(Constants.unauthorized);
      navigatorKey.currentState?.pushReplacementNamed('login');
      clearStorage();
    } else {
      return res;
    }
  }

/*
  * SERVICE NAME: put
  * DESC: Global PUT Method With Token
  * METHOD: PUT
  * Params: url
  */
  put(url) async {
    String token = boxStorage.getToken();
    final header = {
      'Authorization': 'Bearer $token',
      'Bearer': token,
      'Content-Type': 'application/json'
    };
    // var res = await http.put(Uri.parse(url), headers: header);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var res = await ioClient.put(Uri.parse(url), headers: header);
    if (res.statusCode == 401) {
      alertService.errorToast(Constants.unauthorized);
      navigatorKey.currentState?.pushReplacementNamed('login');
      clearStorage();
    } else {
      return res;
    }
  }

  putWithRequestBody(url,requestData) async {
    String token = boxStorage.getToken();
    final header = {
      'Authorization': 'Bearer $token',
      'Bearer': token,
      'Content-Type': 'application/json'
    };
    // var res = await http.put(Uri.parse(url), headers: header);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var res = await ioClient.put(Uri.parse(url),  body: jsonEncode(requestData), headers: header);
    if (res.statusCode == 401) {
      alertService.errorToast(Constants.unauthorized);
      navigatorKey.currentState?.pushReplacementNamed('login');
      clearStorage();
    } else {
      return res;
    }
  }


}
