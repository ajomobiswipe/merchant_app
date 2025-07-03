import 'dart:io';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/static_functions.dart';
import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late final Dio _dio;

  final AlertService _alertService = AlertService();
  final BoxStorage _boxStorage = BoxStorage();

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    ));
    _initSSL();
    _addAuthInterceptor();
  }

  Future<void> _initSSL() async {
    final sslCert = await rootBundle.load('assets/ca/certificate.pem');
    _dio.httpClientAdapter = DefaultHttpClientAdapter(
      onHttpClientCreate: (HttpClient client) {
        final context = SecurityContext(withTrustedRoots: false);
        context.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
        client = HttpClient(context: context);
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => false;
        return client;
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
    print('Request URL: $url');
    final response = await _dio.get(url);
    print('Response: ${response.data}');
    print('Status code: ${response.statusCode}');
    return response;
  }

  Future<Response> post(String url, dynamic data,
      {int timeoutSeconds = 20}) async {
    print("Post");
    print('Request URL: $url');
    print('Request Data: $data');
    final response = await _dio
        .post(url, data: data)
        .timeout(Duration(seconds: timeoutSeconds));
    print('Response: ${response.data}');
    print('Status code: ${response.statusCode}');
    return response;
  }

  // =======================
  // WITHOUT TOKEN REQUESTS
  // =======================

  Future<Response> getWithoutToken(String url) async {
    print("Get without Token");
    print('Request URL: $url');
    final response = await Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    )).get(
      url,
    );
    print('Response: ${response.data}');
    print('Status code: ${response.statusCode}');
    return response;
  }

  Future<Response> postWithoutToken(String url, dynamic data) async {
    print("Post without Token");
    print('Request URL: $url');
    print('Request Data: $data');
    final response = await Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    )).post(
      url,
      data: data,
    );
    print('Response: ${response.data}');
    print('Status code: ${response.statusCode}');
    return response;
  }
}
