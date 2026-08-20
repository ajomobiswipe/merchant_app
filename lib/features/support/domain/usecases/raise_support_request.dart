import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_response_model.dart';
import 'package:anet_merchants/features/support/domain/repository/support_action_repository.dart';

class RaiseSupportRequestParams {
  final String bearerToken;
  final String merchantId;
  final String quickActionMessage;

  const RaiseSupportRequestParams({
    required this.bearerToken,
    required this.merchantId,
    required this.quickActionMessage,
  });
}

class RaiseSupportRequest
    implements
        UseCase<DataState<RaiseSupportResponseModel>,
            RaiseSupportRequestParams> {
  final SupportActionRepository _supportActionRepository;

  RaiseSupportRequest(this._supportActionRepository);

  @override
  Future<DataState<RaiseSupportResponseModel>> call({
    required RaiseSupportRequestParams params,
  }) {
    return _supportActionRepository.raiseSupportRequest(
      bearerToken: params.bearerToken,
      merchantId: params.merchantId,
      quickActionMessage: params.quickActionMessage,
    );
  }
}

