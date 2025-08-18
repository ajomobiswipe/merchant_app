import 'dart:io';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/static_functions.dart';
import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late final Dio _dio;
  SecurityContext? _context;

  final AlertService _alertService = AlertService();
  final BoxStorage _boxStorage = BoxStorage();

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    ));
    _initSSL();
    _addAuthInterceptor();
  }

  Future<void> _initSSL() async {
    final sslCert = await rootBundle.load('assets/ca/certificate.pem');
    _context = SecurityContext(withTrustedRoots: false);
    _context!.setTrustedCertificatesBytes(sslCert.buffer.asInt8List());

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient(context: _context!)
          ..badCertificateCallback = (cert, host, port) => true;
      },
    );
  }

  void _addAuthInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _boxStorage.getToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['Bearer'] = token;
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            NavigationService.navigatorKey.currentState
                ?.pushReplacementNamed('merchantLogin');
            _alertService.error(Constants.unauthorized);
            clearStorage();
            return;
          }
          return handler.next(e);
        },
      ),
    );
  }

  // =======================
  // WITH TOKEN REQUESTS
  // =======================

  Future<Response> get(String url) async {
    if (kDebugMode) print('Request URL: $url');
    final response = await _dio.get(url);
    if (kDebugMode) {
      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');
    }
    return response;
  }

  Future<Response> getWithReqBody(
    String url,
    dynamic data,
  ) async {
    if (kDebugMode) print('Request URL: $url');
    final response = await _dio.get(url, data: data);
    if (kDebugMode) {
      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');
    }
    return response;
  }

  Future<Response> post(String url, dynamic data,
      {int timeoutSeconds = 20}) async {
    if (kDebugMode) {
      print("Post");
      print('Request URL: $url');
      print('Request Data: $data');
    }

    final response = await _dio
        .post(url, data: data)
        .timeout(Duration(seconds: timeoutSeconds));

    if (kDebugMode) {
      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');
    }
    return response;
  }

  // =======================
  // WITHOUT TOKEN REQUESTS
  // =======================

  Future<Response> getWithoutToken(String url) async {
    if (kDebugMode) {
      print("Get without Token");
      print('Request URL: $url');
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient(context: _context!)
          ..badCertificateCallback = (cert, host, port) => true;
      },
    );

    final response = await dio.get(url);
    if (kDebugMode) {
      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');
    }
    return response;
  }

  Future<Response> postWithoutToken(String url, dynamic data) async {
    if (kDebugMode) {
      print("Post without Token");
      print('Request URL: $url');
      print('Request Data: $data');
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient(context: _context!)
          ..badCertificateCallback = (cert, host, port) => true;
      },
    );

    final response = await dio.post(url, data: data);
    if (kDebugMode) {
      print('Response: ${response.data}');
      print('Status code: ${response.statusCode}');
    }
    return response;
  }
}
