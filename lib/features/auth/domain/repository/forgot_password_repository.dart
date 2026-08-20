import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/forgot_password_response_model.dart';

abstract class ForgotPasswordRepository {
  Future<DataState<ForgotPasswordResponseModel>> requestForgotPassword({
    required String username,
  });
}

