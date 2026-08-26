import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/usecases/get_merchant_vpa_txn_data.dart';

part 'merchant_vpa_txn_event.dart';
part 'merchant_vpa_txn_state.dart';

class MerchantVpaTxnBloc
    extends Bloc<MerchantVpaTxnEvent, MerchantVpaTxnState> {
  final GetMerchantVpaTxnData _getMerchantVpaTxnData;
  int _requestGeneration = 0;

  MerchantVpaTxnBloc(this._getMerchantVpaTxnData)
      : super(MerchantVpaTxnInitial()) {
    on<ResetMerchantVpaTxnRequested>((event, emit) {
      _requestGeneration++;
      emit(MerchantVpaTxnInitial());
    });
    on<GetMerchantVpaTxnDataRequested>((event, emit) async {
      final requestGeneration = ++_requestGeneration;
      final requestedPage = _boundedPage(event.page);

      emit(
        MerchantVpaTxnLoading(
          transactions: requestedPage == 0 ? const [] : state.transactions,
          page: requestedPage,
          size: event.size,
          totalPages: requestedPage == 0 ? 0 : state.totalPages,
          totalElements: requestedPage == 0 ? 0 : state.totalElements,
          first: requestedPage == 0 ? true : state.first,
          last: requestedPage == 0 ? true : state.last,
          totalAmount: requestedPage == 0 ? 0 : state.totalAmount,
          selectedVpa: event.creditVpa,
        ),
      );

      try {
        final dataState = await _getMerchantVpaTxnData(
          params: GetMerchantVpaTxnDataParams(
            bearerToken: event.bearerToken,
            creditVpa: event.creditVpa,
            from: event.from,
            to: event.to,
            page: requestedPage,
            size: event.size,
          ),
        );

        if (requestGeneration != _requestGeneration || emit.isDone) return;

        if (dataState is DataSuccess<MerchantVpaTxnResponseModel>) {
          final pageData = dataState.data!.pageData;
          final pagination = _normalizedPagination(
            page: pageData.number,
            totalPages: pageData.totalPages,
          );

          emit(
            MerchantVpaTxnSuccess(
              transactions: pageData.content,
              page: pagination.page,
              size: pageData.size,
              totalPages: pagination.totalPages,
              totalElements: pageData.totalElements,
              first: pagination.first,
              last: pagination.last,
              totalAmount: dataState.data!.totalAmount,
              selectedVpa: event.creditVpa,
            ),
          );
          return;
        }

        if (dataState is DataFailed) {
          emit(
            MerchantVpaTxnFailure(
              error: dataState.error!,
              transactions: state.transactions,
              page: requestedPage,
              size: event.size,
              totalPages: state.totalPages,
              totalElements: state.totalElements,
              first: state.first,
              last: state.last,
              totalAmount: state.totalAmount,
              selectedVpa: event.creditVpa,
            ),
          );
        }
      } on DioException catch (e) {
        if (requestGeneration != _requestGeneration || emit.isDone) return;
        emit(
          MerchantVpaTxnFailure(
            error: e,
            transactions: state.transactions,
            page: requestedPage,
            size: event.size,
            totalPages: state.totalPages,
            totalElements: state.totalElements,
            first: state.first,
            last: state.last,
            totalAmount: state.totalAmount,
            selectedVpa: event.creditVpa,
          ),
        );
      } catch (e) {
        if (requestGeneration != _requestGeneration || emit.isDone) return;
        emit(
          MerchantVpaTxnFailure(
            error: DioException(
              requestOptions: RequestOptions(path: 'merchantVpaTxnData'),
              error: e,
              type: DioExceptionType.unknown,
            ),
            transactions: state.transactions,
            page: requestedPage,
            size: event.size,
            totalPages: state.totalPages,
            totalElements: state.totalElements,
            first: state.first,
            last: state.last,
            totalAmount: state.totalAmount,
            selectedVpa: event.creditVpa,
          ),
        );
      }
    });
  }

  int _boundedPage(int page) {
    final maxPage = state.totalPages > 0 ? state.totalPages - 1 : 0;
    return page.clamp(0, maxPage).toInt();
  }

  _MerchantVpaPagination _normalizedPagination({
    required int page,
    required int totalPages,
  }) {
    final normalizedTotalPages = totalPages < 1 ? 1 : totalPages;
    final normalizedPage = page.clamp(0, normalizedTotalPages - 1).toInt();
    return _MerchantVpaPagination(
      page: normalizedPage,
      totalPages: normalizedTotalPages,
      first: normalizedPage == 0,
      last: normalizedPage == normalizedTotalPages - 1,
    );
  }
}

class _MerchantVpaPagination {
  final int page;
  final int totalPages;
  final bool first;
  final bool last;

  const _MerchantVpaPagination({
    required this.page,
    required this.totalPages,
    required this.first,
    required this.last,
  });
}
