import 'package:anet_merchants/core/config/end_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(dotenv.clean);

  test('uses PROD public and UMS URLs from dotenv by default', () {
    dotenv.loadFromString(
      envString: '''
BASE_API_PUBLIC_PROD=https://prod.example.com:8084
BASE_API_PUBLIC_PROD_UMS=https://prod.example.com:8084/NanoPay/v1/
BASE_API_PUBLIC_UAT=https://uat.example.com:9512
BASE_API_PUBLIC_UAT_UMS=https://uat.example.com:9097/NanoUMS/v1/
BASE_API_LOCAL=http://localhost:9508
BASE_API_LOCAL_UMS=http://localhost:9093/NanoUMS/v1/
''',
    );

    expect(EndPoints.environment, Environment.prod);
    expect(EndPoints.baseApiPublic, 'https://prod.example.com:8084');
    expect(
      EndPoints.baseApiPublicNanoUMS,
      'https://prod.example.com:8084/NanoPay/v1/',
    );
    expect(
      EndPoints.uiApiBaseUrl,
      'https://prod.example.com:8084/NanoPay/Middleware/UiApi/',
    );
  });

  test('throws clear error when required env value is missing', () {
    dotenv.loadFromString(
      envString: '''
BASE_API_PUBLIC_PROD_UMS=https://prod.example.com:8084/NanoPay/v1/
''',
    );

    expect(
      () => EndPoints.baseApiPublic,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Missing environment value: BASE_API_PUBLIC_PROD',
        ),
      ),
    );
  });
}
