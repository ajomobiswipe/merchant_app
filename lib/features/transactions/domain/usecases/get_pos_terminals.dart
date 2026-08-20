import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_terminal_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/repository/pos_transaction_repository.dart';

class GetPosTerminalsParams {
  final String bearerToken;
  final String merchantId;
  final int page;
  final int size;

  const GetPosTerminalsParams({
    required this.bearerToken,
    required this.merchantId,
    required this.page,
    required this.size,
  });
}

class GetPosTerminals
    implements
        UseCase<DataState<PosTerminalResponseModel>, GetPosTerminalsParams> {
  final PosTransactionRepository _repository;

  GetPosTerminals(this._repository);

  @override
  Future<DataState<PosTerminalResponseModel>> call({
    required GetPosTerminalsParams params,
  }) {
    return _repository.getPosTerminals(
      bearerToken: params.bearerToken,
      merchantId: params.merchantId,
      page: params.page,
      size: params.size,
    );
  }
}

