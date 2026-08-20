import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';

abstract class MerchantLoginRepository {
  Future<DataState<UserInfoModel>> login({
    required String username,
    required String password,
  });
}

