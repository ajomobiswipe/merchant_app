import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { UAT, PROD, Local, aws }

class EndPoints {
  static final Environment environment = Environment.aws; // Change as needed

  static String get baseApiPublic {
    switch (environment) {
      case Environment.UAT:
        return dotenv.env['BASE_API_PUBLIC_UAT']!;
      case Environment.PROD:
        return dotenv.env['BASE_API_PUBLIC_PROD']!;
      case Environment.Local:
        return dotenv.env['BASE_API_LOCAL']!;
      case Environment.aws:
        return dotenv.env['BASE_API_UAT_AWS']!;
    }
  }

  static String get baseApiPublicNanoUMS {
    switch (environment) {
      case Environment.UAT:
        return dotenv.env['BASE_API_PUBLIC_UAT_UMS']!;
      case Environment.PROD:
        return dotenv.env['BASE_API_PUBLIC_PROD_UMS']!;
      case Environment.Local:
        return dotenv.env['BASE_API_LOCAL_UMS']!;
      case Environment.aws:
        return dotenv.env['BASE_API_UAT_UMS_AWS']!;
    }
  }
}
