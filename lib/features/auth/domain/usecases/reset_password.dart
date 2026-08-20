import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/auth/data/models/password_reset_response_model.dart';
import 'package:anet_merchants/features/auth/domain/repository/password_reset_repository.dart';

class ResetPasswordParams {
  final String username;
  final String currentPassword;
  final String password;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.username,
    required this.currentPassword,
    required this.password,
    required this.confirmPassword,
  });
}

class ResetPassword
    implements
        UseCase<DataState<PasswordResetResponseModel>, ResetPasswordParams> {
  final PasswordResetRepository _repository;

  ResetPassword(this._repository);

  @override
  Future<DataState<PasswordResetResponseModel>> call({
    required ResetPasswordParams params,
  }) {
    return _repository.resetPassword(
      username: params.username,
      currentPassword: params.currentPassword,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

