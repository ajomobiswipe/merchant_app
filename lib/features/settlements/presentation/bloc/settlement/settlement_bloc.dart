import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/settlements/domain/usecases/get_settlement_history.dart';

part 'settlement_event.dart';
part 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final GetSettlementHistory _getSettlementHistory;
  int _requestGeneration = 0;

  SettlementBloc(this._getSettlementHistory) : super(const SettlementState()) {
    on<ResetSettlementRequested>((event, emit) {
      _requestGeneration++;
      emit(const SettlementState());
    });
    on<GetSettlementHistoryRequested>(_onGetSettlementHistoryRequested);
  }

  Future<void> _onGetSettlementHistoryRequested(
    GetSettlementHistoryRequested event,
    Emitter<SettlementState> emit,
  ) async {
    final requestGeneration = ++_requestGeneration;
    final requestedPage = event.append ? event.page : _boundedPage(event.page);
    final append = event.append && requestedPage > 0;

    emit(
      state.copyWith(
        isLoading: true,
        page: requestedPage,
        error: null,
        settlements: append ? state.settlements : const [],
        settledTransactions:
            append ? state.settledTransactions : const [],
        totalPages: append ? state.totalPages : 0,
        totalElements: append ? state.totalElements : 0,
        transactionCount: append ? state.transactionCount : 0,
        totalAmount: append ? state.totalAmount : 0,
        first: append ? state.first : true,
        last: append ? state.last : true,
      ),
    );

    final dataState = await _getSettlementHistory(
      params: GetSettlementHistoryParams(
        bearerToken: event.bearerToken,
        merchantId: event.merchantId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        page: requestedPage,
        size: event.size,
        sendSettlementReportToMail: event.sendSettlementReportToMail,
      ),
    );

    if (requestGeneration != _requestGeneration || emit.isDone) return;

    if (dataState is DataSuccess<SettlementHistoryResponseModel>) {
      final page = dataState.data!.settlementAggregatePage;
      final settledSummaryPage = dataState.data!.settledSummaryPage;
      final total = dataState.data!.settlementTotal;
      final pagination = _normalizedPagination(
        page: page.number,
        totalPages: page.totalPages,
      );

      emit(
        state.copyWith(
          settlements: append
              ? _appendUniqueSettlements(state.settlements, page.content)
              : page.content,
          settledTransactions: append
              ? _appendUniqueSettlements(
                  state.settledTransactions,
                  settledSummaryPage.content,
                )
              : settledSummaryPage.content,
          isLoading: false,
          page: pagination.page,
          size: page.size,
          totalPages: pagination.totalPages,
          totalElements: total.settlementCount == 0
              ? page.totalElements
              : total.settlementCount,
          first: pagination.first,
          last: pagination.last,
          totalAmount: total.totalAmount,
          transactionCount: total.transactionCount,
          error: null,
        ),
      );
      return;
    }

    if (dataState is DataFailed) {
      emit(
        state.copyWith(
          isLoading: false,
          error: dataState.error,
        ),
      );
    }
  }

  List<SettlementItemModel> _appendUniqueSettlements(
    List<SettlementItemModel> current,
    List<SettlementItemModel> incoming,
  ) {
    final existing = current
        .map((item) => '${item.utr}|${item.rrn}|${item.tranDate}')
        .toSet();
    return [
      ...current,
      ...incoming.where(
        (item) => existing.add('${item.utr}|${item.rrn}|${item.tranDate}'),
      ),
    ];
  }

  int _boundedPage(int page) {
    final maxPage = state.totalPages > 0 ? state.totalPages - 1 : 0;
    return page.clamp(0, maxPage).toInt();
  }

  _SettlementPagination _normalizedPagination({
    required int page,
    required int totalPages,
  }) {
    final normalizedTotalPages = totalPages < 1 ? 1 : totalPages;
    final normalizedPage = page.clamp(0, normalizedTotalPages - 1).toInt();
    return _SettlementPagination(
      page: normalizedPage,
      totalPages: normalizedTotalPages,
      first: normalizedPage == 0,
      last: normalizedPage == normalizedTotalPages - 1,
    );
  }
}

class _SettlementPagination {
  final int page;
  final int totalPages;
  final bool first;
  final bool last;

  const _SettlementPagination({
    required this.page,
    required this.totalPages,
    required this.first,
    required this.last,
  });
}
