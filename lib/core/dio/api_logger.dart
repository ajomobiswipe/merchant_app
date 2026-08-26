import 'package:dio/dio.dart';
import 'package:anet_merchants/core/utils/unauthorized_session_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiLogger extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      logger.i(
        'REQUEST [${options.method}] => ${options.uri}\n'
        'Headers: ${_redact(options.headers)}\n'
        'Body: ${_redact(options.data)}',
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      logger.i(
        'RESPONSE [${response.statusCode}] => '
        '${response.requestOptions.uri}\n${_redact(response.data)}',
      );
    }

    if (response.statusCode == 401) {
      UnauthorizedSessionHandler.handleUnauthorized();
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      logger.e(
        'ERROR [${err.response?.statusCode}] => ${err.requestOptions.uri}',
        error: err.message,
      );
    }

    if (err.response?.statusCode == 401) {
      UnauthorizedSessionHandler.handleUnauthorized();
    }

    handler.next(err);
  }
}

dynamic _redact(dynamic value) {
  if (value is Map) {
    return value.map((key, item) {
      final normalizedKey = key.toString().toLowerCase();
      final isSensitive = normalizedKey.contains('password') ||
          normalizedKey.contains('token') ||
          normalizedKey.contains('authorization') ||
          normalizedKey.contains('secret');

      return MapEntry(key, isSensitive ? '[REDACTED]' : _redact(item));
    });
  }

  if (value is Iterable) {
    return value.map(_redact).toList(growable: false);
  }

  return value;
}
