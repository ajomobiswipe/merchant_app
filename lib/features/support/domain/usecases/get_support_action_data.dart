import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';
import 'package:anet_merchants/features/support/domain/repository/support_action_repository.dart';

class GetSupportActionDataParams {
  final String bearerToken;

  const GetSupportActionDataParams({
    required this.bearerToken,
  });
}

class GetSupportActionData
    implements
        UseCase<DataState<SupportActionResponseModel>,
            GetSupportActionDataParams> {
  final SupportActionRepository _supportActionRepository;

  GetSupportActionData(this._supportActionRepository);

  @override
  Future<DataState<SupportActionResponseModel>> call({
    required GetSupportActionDataParams params,
  }) {
    return _supportActionRepository.getSupportActionData(
      bearerToken: params.bearerToken,
    );
  }
}

