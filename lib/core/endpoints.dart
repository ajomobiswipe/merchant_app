import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { UAT, PROD, Local }

class EndPoints {
  static final Environment environment = Environment.UAT; // Change as needed

  static String get baseApiPublic {
    switch (environment) {
      case Environment.UAT:
        return dotenv.env['BASE_API_PUBLIC_UAT']!;
      case Environment.PROD:
        return dotenv.env['BASE_API_PUBLIC_PROD']!;
      case Environment.Local:
        return dotenv.env['BASE_API_LOCAL']!;
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
    }
  }
}
