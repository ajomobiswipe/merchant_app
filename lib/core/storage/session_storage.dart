import 'dart:convert';

import 'package:anet_merchants/features/auth/data/models/user_info.dart';

import 'session_storage_backend.dart';
import 'session_storage_backend_factory.dart';

class SessionStorage {
  final SessionStorageBackend _storage;
  static const _loginSuccessKey = 'login_success';
  static const _userInfoKey = 'user_info';
  static const _activeAcqMerchantIdKey = 'active_acq_merchant_id';
  static const _activeShopNameKey = 'active_shop_name';

  SessionStorage({SessionStorageBackend? storage})
      : _storage = storage ?? createSessionStorageBackend();

  Future<void> saveLoginResponse(UserInfoModel userInfo) async {
    // Persist the full login payload once so later API calls can read
    // token, merchant selection, feature flags, and profile data from one source.
    await _storage.write(_loginSuccessKey, 'true');
    await _storage.write(
      _userInfoKey,
      jsonEncode(userInfo.toJson()),
    );
    await setActiveMerchantSelection(
      acqMerchantId: userInfo.acqMerchantId,
      shopName: userInfo.shopName,
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(_loginSuccessKey);
    await _storage.delete(_userInfoKey);
    await _storage.delete(_activeAcqMerchantIdKey);
    await _storage.delete(_activeShopNameKey);
  }

  Future<void> setActiveMerchantSelection({
    required String acqMerchantId,
    required String shopName,
  }) async {
    await _storage.write(_activeAcqMerchantIdKey, acqMerchantId);
    await _storage.write(_activeShopNameKey, shopName);
  }

  Future<bool> get isLoginSuccess async {
    return await _storage.read(_loginSuccessKey) == 'true';
  }

  Future<UserInfoModel?> get userInfo async {
    final rawUserInfo = await _storage.read(_userInfoKey);

    if (rawUserInfo == null || rawUserInfo.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawUserInfo);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return UserInfoModel.fromJson(decoded);
  }

  Future<String> get firstName async => (await userInfo)?.firstName ?? '';
  Future<String> get lastName async => (await userInfo)?.lastName ?? '';
  Future<String> get userName async => (await userInfo)?.userName ?? '';
  Future<String> get email async => (await userInfo)?.email ?? '';
  Future<String> get shopName async => (await userInfo)?.shopName ?? '';
  Future<String> get activeShopName async {
    final activeShopName = await _storage.read(_activeShopNameKey);
    if (activeShopName != null && activeShopName.isNotEmpty) {
      return activeShopName;
    }

    return shopName;
  }

  Future<String> get activeMerchantDisplayLabel async {
    // Dropdown screens store only the active acquiring merchant id.
    // This helper resolves the user-facing label without forcing each screen
    // to re-implement the lookup logic.
    final selectedMerchantId = await activeAcqMerchantId;
    final dropdownItems = await merchantDropdownItems;

    for (final item in dropdownItems) {
      if (item.merchantId == selectedMerchantId) {
        return item.displayLabel;
      }
    }

    final selectedShopName = await activeShopName;
    if (selectedShopName.isNotEmpty) {
      return selectedShopName;
    }

    return shopName;
  }

  Future<String> get responseCode async => (await userInfo)?.responseCode ?? '';
  Future<String> get responseMessage async =>
      (await userInfo)?.responseMessage ?? '';
  Future<String> get instId async => (await userInfo)?.instId ?? '';
  Future<String> get custId async => (await userInfo)?.custId ?? '';
  Future<String> get role async => (await userInfo)?.role ?? '';
  Future<int> get roleId async => (await userInfo)?.roleId ?? 0;
  Future<int> get productId async => (await userInfo)?.productId ?? 0;
  Future<String> get productName async => (await userInfo)?.productName ?? '';
  Future<String> get deviceType async => (await userInfo)?.deviceType ?? '';
  Future<String> get merchantId async => (await userInfo)?.merchantId ?? '';
  Future<String> get acqMerchantId async =>
      (await userInfo)?.acqMerchantId ?? '';
  Future<String> get activeAcqMerchantId async {
    final activeAcqMerchantId = await _storage.read(_activeAcqMerchantIdKey);
    if (activeAcqMerchantId != null && activeAcqMerchantId.isNotEmpty) {
      return activeAcqMerchantId;
    }

    return acqMerchantId;
  }

  Future<String> get bearerToken async => (await userInfo)?.bearerToken ?? '';
  Future<bool> get passFlag async => (await userInfo)?.passFlag ?? false;
  Future<bool> get checker async => (await userInfo)?.checker ?? false;
  Future<String> get cid async => (await userInfo)?.cid ?? '';
  Future<String> get userRoleType async => (await userInfo)?.userRoleType ?? '';
  Future<bool> get isChecker async => (await userInfo)?.isChecker ?? false;
  Future<int> get twoFAOTPTimer async => (await userInfo)?.twoFAOTPTimer ?? 0;
  Future<String> get dashboardEnabled async =>
      (await userInfo)?.dashboardEnabled ?? '';
  Future<bool> get isDashboardEnabled async =>
      (await userInfo)?.isDashboardEnabled ?? false;
  Future<bool> get twoFARequired async =>
      (await userInfo)?.twoFARequired ?? false;
  Future<String> get userType async => (await userInfo)?.userType ?? '';
  Future<String> get terminalId async => (await userInfo)?.terminalId ?? '';
  Future<List<MerchantDropdownItem>> get merchantDropdownItems async =>
      (await userInfo)?.merchantDropdownItems ?? const [];
}
