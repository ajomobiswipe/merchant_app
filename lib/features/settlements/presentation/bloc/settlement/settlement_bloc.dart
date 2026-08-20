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

  SettlementBloc(this._getSettlementHistory) : super(const SettlementState()) {
    on<GetSettlementHistoryRequested>(_onGetSettlementHistoryRequested);
  }

  Future<void> _onGetSettlementHistoryRequested(
    GetSettlementHistoryRequested event,
    Emitter<SettlementState> emit,
  ) async {
    final requestedPage = _boundedPage(event.page);

    emit(
      state.copyWith(
        isLoading: true,
        page: requestedPage,
        error: null,
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
          settlements: page.content,
          settledTransactions: settledSummaryPage.content,
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
