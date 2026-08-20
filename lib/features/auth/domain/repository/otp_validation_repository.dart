import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/otp_validation_response_model.dart';

abstract class OtpValidationRepository {
  Future<DataState<OtpValidationResponseModel>> verifyEmailOtp({
    required String username,
    required String otp,
  });
}

