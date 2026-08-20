import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';

abstract class MerchantVpaTxnRepository {
  Future<DataState<MerchantVpaTxnResponseModel>> getMerchantVpaTxnData({
    required String bearerToken,
    required String creditVpa,
    required String from,
    required String to,
    required int page,
    required int size,
    String? mappedMerchantId,
  });
}

