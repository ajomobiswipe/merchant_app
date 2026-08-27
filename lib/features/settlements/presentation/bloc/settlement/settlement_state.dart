part of 'settlement_bloc.dart';

class SettlementState extends Equatable {
  final List<SettlementItemModel> settlements;
  final List<SettlementItemModel> settledTransactions;
  final bool isLoading;
  final DioException? error;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;
  final int transactionCount;
  final bool first;
  final bool last;
  final double totalAmount;
  final int transactionPage;
  final int transactionTotalPages;
  final bool transactionFirst;
  final bool transactionLast;

  const SettlementState({
    this.settlements = const [],
    this.settledTransactions = const [],
    this.isLoading = false,
    this.error,
    this.page = 0,
    this.size = 10,
    this.totalPages = 0,
    this.totalElements = 0,
    this.transactionCount = 0,
    this.first = true,
    this.last = true,
    this.totalAmount = 0,
    this.transactionPage = 0,
    this.transactionTotalPages = 0,
    this.transactionFirst = true,
    this.transactionLast = true,
  });

  SettlementState copyWith({
    List<SettlementItemModel>? settlements,
    List<SettlementItemModel>? settledTransactions,
    bool? isLoading,
    DioException? error,
    int? page,
    int? size,
    int? totalPages,
    int? totalElements,
    int? transactionCount,
    bool? first,
    bool? last,
    double? totalAmount,
    int? transactionPage,
    int? transactionTotalPages,
    bool? transactionFirst,
    bool? transactionLast,
  }) {
    return SettlementState(
      settlements: settlements ?? this.settlements,
      settledTransactions: settledTransactions ?? this.settledTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      size: size ?? this.size,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      transactionCount: transactionCount ?? this.transactionCount,
      first: first ?? this.first,
      last: last ?? this.last,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionPage: transactionPage ?? this.transactionPage,
      transactionTotalPages:
          transactionTotalPages ?? this.transactionTotalPages,
      transactionFirst: transactionFirst ?? this.transactionFirst,
      transactionLast: transactionLast ?? this.transactionLast,
    );
  }

  @override
  List<Object?> get props => [
        settlements,
        settledTransactions,
        isLoading,
        error,
        page,
        size,
        totalPages,
        totalElements,
        transactionCount,
        first,
        last,
        totalAmount,
        transactionPage,
        transactionTotalPages,
        transactionFirst,
        transactionLast,
      ];
}
