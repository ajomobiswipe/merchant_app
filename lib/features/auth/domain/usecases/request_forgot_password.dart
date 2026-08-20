import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/auth/data/models/forgot_password_response_model.dart';
import 'package:anet_merchants/features/auth/domain/repository/forgot_password_repository.dart';

class RequestForgotPasswordParams {
  final String username;

  const RequestForgotPasswordParams({required this.username});
}

class RequestForgotPassword
    implements
        UseCase<DataState<ForgotPasswordResponseModel>,
            RequestForgotPasswordParams> {
  final ForgotPasswordRepository _repository;

  const RequestForgotPassword(this._repository);

  @override
  Future<DataState<ForgotPasswordResponseModel>> call({
    required RequestForgotPasswordParams params,
  }) {
    return _repository.requestForgotPassword(username: params.username);
  }
}

