import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { uat, prod, local }

class EndPoints {
  const EndPoints._();

  static const String _configuredEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static Environment get environment {
    switch (_configuredEnvironment.toLowerCase()) {
      case 'uat':
        return Environment.uat;
      case 'prod':
        return Environment.prod;
      case 'local':
        return Environment.local;
      default:
        throw StateError(
          'Unsupported APP_ENV: $_configuredEnvironment. '
          'Expected uat, prod, or local.',
        );
    }
  }

  static String get baseApiPublic {
    switch (environment) {
      case Environment.uat:
        return _env('BASE_API_PUBLIC_UAT');
      case Environment.prod:
        return _env('BASE_API_PUBLIC_PROD');
      case Environment.local:
        return _env('BASE_API_LOCAL');
    }
  }

  static String get baseApiPublicNanoUMS {
    switch (environment) {
      case Environment.uat:
        return _env('BASE_API_PUBLIC_UAT_UMS');
      case Environment.prod:
        return _env('BASE_API_PUBLIC_PROD_UMS');
      case Environment.local:
        return _env('BASE_API_LOCAL_UMS');
    }
  }

  static String get uiApiBaseUrl {
    return '${_withoutTrailingSlash(baseApiPublic)}/NanoPay/Middleware/UiApi/';
  }

  static String _env(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing environment value: $key');
    }
    return value.trim();
  }

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
