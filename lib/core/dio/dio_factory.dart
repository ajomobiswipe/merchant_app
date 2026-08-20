import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:anet_merchants/core/dio/api_logger.dart';

class DioFactory {
  static Future<Dio> create() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'content-type': 'application/json'},
      ),
    );

    dio.interceptors.add(ApiLogger());

    // Browsers manage their own certificate store and do not support
    // `SecurityContext` or a custom `HttpClient`.
    if (kIsWeb) return dio;

    // Load SSL certificate on native platforms.
    final certBytes =
        await rootBundle.load('assets/certificates/certificate.pem');

    final securityContext = SecurityContext(
      withTrustedRoots: false,
    );

    securityContext.setTrustedCertificatesBytes(
      certBytes.buffer.asUint8List(),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient(context: securityContext)
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            return true;
          };
      },
    );

    return dio;
  }
}
