import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_terminal_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/usecases/get_pos_terminals.dart';
import 'package:anet_merchants/features/transactions/domain/usecases/get_pos_transactions.dart';

part 'pos_transaction_event.dart';
part 'pos_transaction_state.dart';

class PosTransactionBloc
    extends Bloc<PosTransactionEvent, PosTransactionState> {
  final GetPosTerminals _getPosTerminals;
  final GetPosTransactions _getPosTransactions;
  int _terminalRequestGeneration = 0;
  int _transactionRequestGeneration = 0;

  PosTransactionBloc(this._getPosTerminals, this._getPosTransactions)
      : super(const PosTransactionState()) {
    on<GetPosTerminalsRequested>(_onGetPosTerminalsRequested);
    on<GetPosTransactionsRequested>(_onGetPosTransactionsRequested);
  }

  Future<void> _onGetPosTerminalsRequested(
    GetPosTerminalsRequested event,
    Emitter<PosTransactionState> emit,
  ) async {
    final requestGeneration = ++_terminalRequestGeneration;
    emit(state.copyWith(terminalsLoading: true, terminalError: null));

    final dataState = await _getPosTerminals(
      params: GetPosTerminalsParams(
        bearerToken: event.bearerToken,
        merchantId: event.merchantId,
        page: event.page,
        size: event.size,
      ),
    );

    if (requestGeneration != _terminalRequestGeneration || emit.isDone) return;

    if (dataState is DataSuccess<PosTerminalResponseModel>) {
      emit(
        state.copyWith(
          terminals: dataState.data!.content,
          terminalsLoading: false,
          terminalError: null,
        ),
      );
      return;
    }

    if (dataState is DataFailed) {
      emit(
        state.copyWith(
          terminalsLoading: false,
          terminalError: dataState.error,
        ),
      );
    }
  }

  Future<void> _onGetPosTransactionsRequested(
    GetPosTransactionsRequested event,
    Emitter<PosTransactionState> emit,
  ) async {
    final requestGeneration = ++_transactionRequestGeneration;
    final requestedPage = _boundedPage(event.page);

    emit(
      state.copyWith(
        transactionsLoading: true,
        transactionError: null,
        page: requestedPage,
        transactions: requestedPage == 0 ? const [] : state.transactions,
        terminalSummaries:
            requestedPage == 0 ? const [] : state.terminalSummaries,
        totalElements: requestedPage == 0 ? 0 : state.totalElements,
        totalAmount: requestedPage == 0 ? 0 : state.totalAmount,
        totalPages: requestedPage == 0 ? 0 : state.totalPages,
        first: requestedPage == 0 ? true : state.first,
        last: requestedPage == 0 ? true : state.last,
        selectedTerminalId: event.terminalId,
      ),
    );

    final dataState = await _getPosTransactions(
      params: GetPosTransactionsParams(
        bearerToken: event.bearerToken,
        clientUniqueId: event.clientUniqueId,
        merchantId: event.merchantId,
        acquirerId: event.acquirerId,
        page: requestedPage,
        size: event.size,
        recordFrom: event.recordFrom,
        recordTo: event.recordTo,
        rrn: event.rrn,
        authCode: event.authCode,
        terminalId: event.terminalId,
        sourceOfTxn: event.sourceOfTxn,
        mid: event.mid,
        creditVpa: event.creditVpa,
        useMidEndpoint: event.useMidEndpoint,
        sendTxnReportToMail: event.sendTxnReportToMail,
      ),
    );

    if (requestGeneration != _transactionRequestGeneration || emit.isDone) {
      return;
    }

    if (dataState is DataSuccess<PosTxnHistoryResponseModel>) {
      final page = dataState.data!.responsePage;
      final pagination = _normalizedPagination(
        page: page.number,
        totalPages: page.totalPages,
      );

      emit(
        state.copyWith(
          transactions: page.content,
          transactionsLoading: false,
          transactionError: null,
          page: pagination.page,
          size: page.size,
          totalPages: pagination.totalPages,
          totalElements: dataState.data!.count,
          first: pagination.first,
          last: pagination.last,
          totalAmount: dataState.data!.totalAmount,
          selectedTerminalId: event.terminalId,
          terminalSummaries: dataState.data!.terminalSummaries,
        ),
      );
      return;
    }

    if (dataState is DataFailed) {
      emit(
        state.copyWith(
          transactionsLoading: false,
          transactionError: dataState.error,
        ),
      );
    }
  }

  int _boundedPage(int page) {
    final maxPage = state.totalPages > 0 ? state.totalPages - 1 : 0;
    return page.clamp(0, maxPage).toInt();
  }

  _PaginationState _normalizedPagination({
    required int page,
    required int totalPages,
  }) {
    final normalizedTotalPages = totalPages < 1 ? 1 : totalPages;
    final normalizedPage = page.clamp(0, normalizedTotalPages - 1).toInt();
    return _PaginationState(
      page: normalizedPage,
      totalPages: normalizedTotalPages,
      first: normalizedPage == 0,
      last: normalizedPage == normalizedTotalPages - 1,
    );
  }
}

class _PaginationState {
  final int page;
  final int totalPages;
  final bool first;
  final bool last;

  const _PaginationState({
    required this.page,
    required this.totalPages,
    required this.first,
    required this.last,
  });
}
