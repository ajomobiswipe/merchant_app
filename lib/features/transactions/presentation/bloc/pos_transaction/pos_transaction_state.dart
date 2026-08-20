part of 'pos_transaction_bloc.dart';

class PosTransactionState extends Equatable {
  final List<String> terminals;
  final List<PosTransactionModel> transactions;
  final bool terminalsLoading;
  final bool transactionsLoading;
  final DioException? terminalError;
  final DioException? transactionError;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final double totalAmount;
  final String? selectedTerminalId;
  final List<PosTerminalSummaryModel> terminalSummaries;

  const PosTransactionState({
    this.terminals = const [],
    this.transactions = const [],
    this.terminalsLoading = false,
    this.transactionsLoading = false,
    this.terminalError,
    this.transactionError,
    this.page = 0,
    this.size = 10,
    this.totalPages = 0,
    this.totalElements = 0,
    this.first = true,
    this.last = true,
    this.totalAmount = 0,
    this.selectedTerminalId,
    this.terminalSummaries = const [],
  });

  PosTransactionState copyWith({
    List<String>? terminals,
    List<PosTransactionModel>? transactions,
    bool? terminalsLoading,
    bool? transactionsLoading,
    DioException? terminalError,
    DioException? transactionError,
    int? page,
    int? size,
    int? totalPages,
    int? totalElements,
    bool? first,
    bool? last,
    double? totalAmount,
    String? selectedTerminalId,
    List<PosTerminalSummaryModel>? terminalSummaries,
  }) {
    return PosTransactionState(
      terminals: terminals ?? this.terminals,
      transactions: transactions ?? this.transactions,
      terminalsLoading: terminalsLoading ?? this.terminalsLoading,
      transactionsLoading: transactionsLoading ?? this.transactionsLoading,
      terminalError: terminalError,
      transactionError: transactionError,
      page: page ?? this.page,
      size: size ?? this.size,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      first: first ?? this.first,
      last: last ?? this.last,
      totalAmount: totalAmount ?? this.totalAmount,
      selectedTerminalId: selectedTerminalId ?? this.selectedTerminalId,
      terminalSummaries: terminalSummaries ?? this.terminalSummaries,
    );
  }

  @override
  List<Object?> get props => [
        terminals,
        transactions,
        terminalsLoading,
        transactionsLoading,
        terminalError,
        transactionError,
        page,
        size,
        totalPages,
        totalElements,
        first,
        last,
        totalAmount,
        selectedTerminalId,
        terminalSummaries,
      ];
}
