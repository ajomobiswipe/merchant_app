import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:anet_merchants/features/auth/domain/repository/merchant_login_repository.dart';

class UserLoginParams {
  final String username;
  final String password;

  const UserLoginParams({
    required this.username,
    required this.password,
  });
}

class UserLogin implements UseCase<DataState<UserInfoModel>, UserLoginParams> {
  final MerchantLoginRepository _merchantLoginRepository;

  UserLogin(this._merchantLoginRepository);

  @override
  Future<DataState<UserInfoModel>> call({required UserLoginParams params}) {
    return _merchantLoginRepository.login(
      username: params.username,
      password: params.password,
    );
  }
}

