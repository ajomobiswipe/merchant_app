import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/password_reset_response_model.dart';

abstract class PasswordResetRepository {
  Future<DataState<PasswordResetResponseModel>> resetPassword({
    required String username,
    required String currentPassword,
    required String password,
    required String confirmPassword,
  });
}

