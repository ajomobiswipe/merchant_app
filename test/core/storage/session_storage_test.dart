import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/storage/session_storage_backend.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionStorage storage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = SessionStorage();
  });

  test('saves login success flag and exposes login response getters', () async {
    await storage.saveLoginResponse(_userInfo);

    expect(await storage.isLoginSuccess, isTrue);
    expect(await storage.shopName, 'Merchant Shop');
    expect(await storage.userName, 'merchant_user');
    expect(await storage.merchantId, 'AXISM0000001959');
    expect(await storage.acqMerchantId, '651010000022371');
    expect(await storage.activeAcqMerchantId, '651010000022371');
    expect(await storage.activeShopName, 'Merchant Shop');
    expect(await storage.bearerToken, 'token');
    expect(await storage.passFlag, isTrue);
    expect(await storage.dashboardEnabled, 'Y');
    expect(await storage.isDashboardEnabled, isTrue);
    expect(await storage.userType, 'merchant');
    expect(await storage.terminalId, '51169086');
    expect(await storage.twoFARequired, isFalse);
    expect((await storage.merchantDropdownItems).length, 2);

    await storage.setActiveMerchantSelection(
      acqMerchantId: '0',
      shopName: 'All',
    );

    expect(await storage.activeAcqMerchantId, '0');
    expect(await storage.activeShopName, 'All');
  });

  test('clears login success flag and user information', () async {
    await storage.saveLoginResponse(_userInfo);

    await storage.clearSession();

    expect(await storage.isLoginSuccess, isFalse);
    expect(await storage.userInfo, isNull);
    expect(await storage.bearerToken, isEmpty);
    expect(await storage.merchantId, isEmpty);
    expect(await storage.activeAcqMerchantId, isEmpty);
    expect(await storage.activeShopName, isEmpty);
  });

  test('independent storage backends do not share merchant sessions', () async {
    final firstTab = SessionStorage(storage: _MemorySessionStorageBackend());
    final secondTab = SessionStorage(storage: _MemorySessionStorageBackend());

    await firstTab.saveLoginResponse(_userInfo);

    expect(await firstTab.isLoginSuccess, isTrue);
    expect(await firstTab.merchantId, 'AXISM0000001959');
    expect(await secondTab.isLoginSuccess, isFalse);
    expect(await secondTab.merchantId, isEmpty);

    await secondTab.saveLoginResponse(
      UserInfoModel.fromJson({
        ..._userInfo.toJson(),
        'merchantId': 'AXISM0000002000',
        'acqMerchantId': '651010000099999',
        'shopName': 'Second Merchant',
      }),
    );

    expect(await firstTab.merchantId, 'AXISM0000001959');
    expect(await secondTab.merchantId, 'AXISM0000002000');

    await firstTab.clearSession();

    expect(await firstTab.isLoginSuccess, isFalse);
    expect(await secondTab.isLoginSuccess, isTrue);
  });
}

final class _MemorySessionStorageBackend implements SessionStorageBackend {
  final Map<String, String> _values = {};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

final _userInfo = UserInfoModel(
  firstName: 'Test',
  lastName: 'Merchant',
  userName: 'merchant_user',
  email: 'merchant@example.com',
  shopName: 'Merchant Shop',
  responseCode: '00',
  responseMessage: 'Success',
  instId: 'OMAIND',
  custId: '1',
  role: 'MERCHANT USER',
  roleId: 1,
  productId: 1,
  productName: 'NanoPay',
  deviceType: 'MOBAPP',
  merchantId: 'AXISM0000001959',
  acqMerchantId: '651010000022371',
  bearerToken: 'token',
  passFlag: true,
  checker: false,
  cid: '',
  userRoleType: 'MERCHANT',
  isChecker: false,
  twoFAOTPTimer: 0,
  dashboardEnabled: 'Y',
  twoFARequired: false,
  userType: 'merchant',
  terminalId: '51169086',
  merchantIds: const {
    '651010000022371': 'Merchant Shop',
  },
  merchantInfoForDashboard: const [],
);
