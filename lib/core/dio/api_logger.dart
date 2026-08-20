import 'package:dio/dio.dart';
import 'package:anet_merchants/core/utils/unauthorized_session_handler.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiLogger extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    logger.i(
      'REQUEST [${options.method}] => ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Body: ${options.data}',
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    logger.i(
      'RESPONSE [${response.statusCode}] => ${response.requestOptions.uri}\n'
      '${response.data}',
    );

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
    logger.e(
      'ERROR [${err.response?.statusCode}] => ${err.requestOptions.uri}',
      error: err,
    );

    if (err.response?.statusCode == 401) {
      UnauthorizedSessionHandler.handleUnauthorized();
    }

    handler.next(err);
  }
}
