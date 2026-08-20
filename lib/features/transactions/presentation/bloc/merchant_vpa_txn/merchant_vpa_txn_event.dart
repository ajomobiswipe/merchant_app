part of 'merchant_vpa_txn_bloc.dart';

sealed class MerchantVpaTxnEvent extends Equatable {
  const MerchantVpaTxnEvent();

  @override
  List<Object> get props => [];
}

class GetMerchantVpaTxnDataRequested extends MerchantVpaTxnEvent {
  final String bearerToken;
  final String creditVpa;
  final String from;
  final String to;
  final int page;
  final int size;

  const GetMerchantVpaTxnDataRequested({
    required this.bearerToken,
    required this.creditVpa,
    required this.from,
    required this.to,
    required this.page,
    this.size = 10,
  });

  @override
  List<Object> get props => [
        bearerToken,
        creditVpa,
        from,
        to,
        page,
        size,
      ];
}
