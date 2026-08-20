import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/auth/data/models/otp_validation_response_model.dart';
import 'package:anet_merchants/features/auth/domain/repository/otp_validation_repository.dart';

class VerifyEmailOtpParams {
  final String username;
  final String otp;

  const VerifyEmailOtpParams({
    required this.username,
    required this.otp,
  });
}

class VerifyEmailOtp
    implements
        UseCase<DataState<OtpValidationResponseModel>, VerifyEmailOtpParams> {
  final OtpValidationRepository _repository;

  const VerifyEmailOtp(this._repository);

  @override
  Future<DataState<OtpValidationResponseModel>> call({
    required VerifyEmailOtpParams params,
  }) {
    return _repository.verifyEmailOtp(
      username: params.username,
      otp: params.otp,
    );
  }
}

