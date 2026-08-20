import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_response_model.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';

abstract class SupportActionRepository {
  Future<DataState<SupportActionResponseModel>> getSupportActionData({
    required String bearerToken,
  });

  Future<DataState<RaiseSupportResponseModel>> raiseSupportRequest({
    required String bearerToken,
    required String merchantId,
    required String quickActionMessage,
  });
}

