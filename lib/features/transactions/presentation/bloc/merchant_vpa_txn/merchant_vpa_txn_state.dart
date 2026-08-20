part of 'merchant_vpa_txn_bloc.dart';

abstract class MerchantVpaTxnState extends Equatable {
  final List<MerchantVpaTransactionModel> transactions;
  final DioException? error;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final double totalAmount;
  final String? selectedVpa;

  const MerchantVpaTxnState({
    this.transactions = const [],
    this.error,
    this.page = 0,
    this.size = 10,
    this.totalPages = 0,
    this.totalElements = 0,
    this.first = true,
    this.last = true,
    this.totalAmount = 0,
    this.selectedVpa,
  });

  @override
  List<Object?> get props => [
        transactions,
        error,
        page,
        size,
        totalPages,
        totalElements,
        first,
        last,
        totalAmount,
        selectedVpa,
      ];
}

class MerchantVpaTxnInitial extends MerchantVpaTxnState {}

class MerchantVpaTxnLoading extends MerchantVpaTxnState {
  const MerchantVpaTxnLoading({
    super.transactions,
    super.page,
    super.size,
    super.totalPages,
    super.totalElements,
    super.first,
    super.last,
    super.totalAmount,
    super.selectedVpa,
  });
}

class MerchantVpaTxnSuccess extends MerchantVpaTxnState {
  const MerchantVpaTxnSuccess({
    required super.transactions,
    required super.page,
    required super.size,
    required super.totalPages,
    required super.totalElements,
    required super.first,
    required super.last,
    required super.totalAmount,
    required super.selectedVpa,
  });
}

class MerchantVpaTxnFailure extends MerchantVpaTxnState {
  const MerchantVpaTxnFailure({
    required DioException error,
    super.transactions,
    super.page,
    super.size,
    super.totalPages,
    super.totalElements,
    super.first,
    super.last,
    super.totalAmount,
    super.selectedVpa,
  }) : super(error: error);
}
