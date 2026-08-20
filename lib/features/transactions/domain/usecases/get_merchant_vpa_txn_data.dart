import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/repository/merchant_vpa_txn_repository.dart';

class GetMerchantVpaTxnDataParams {
  final String bearerToken;
  final String creditVpa;
  final String from;
  final String to;
  final int page;
  final int size;
  final String? mappedMerchantId;

  const GetMerchantVpaTxnDataParams({
    required this.bearerToken,
    required this.creditVpa,
    required this.from,
    required this.to,
    required this.page,
    required this.size,
    this.mappedMerchantId,
  });
}

class GetMerchantVpaTxnData
    implements
        UseCase<DataState<MerchantVpaTxnResponseModel>,
            GetMerchantVpaTxnDataParams> {
  final MerchantVpaTxnRepository _merchantVpaTxnRepository;

  GetMerchantVpaTxnData(this._merchantVpaTxnRepository);

  @override
  Future<DataState<MerchantVpaTxnResponseModel>> call({
    required GetMerchantVpaTxnDataParams params,
  }) {
    return _merchantVpaTxnRepository.getMerchantVpaTxnData(
      bearerToken: params.bearerToken,
      creditVpa: params.creditVpa,
      from: params.from,
      to: params.to,
      page: params.page,
      size: params.size,
      mappedMerchantId: params.mappedMerchantId,
    );
  }
}

