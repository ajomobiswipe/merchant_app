import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_request_model.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_terminal_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MerchantVpaTxnRequestModel', () {
    test('serializes date range and selected credit VPA', () {
      const request = MerchantVpaTxnRequestModel(
        from: '10-06-2026',
        to: '10-06-2026',
        creditVpa: 'hardwarisweets.anet@axisbank',
      );

      expect(request.toJson(), {
        'from': '10-06-2026',
        'to': '10-06-2026',
        'creditVpa': 'hardwarisweets.anet@axisbank',
      });
    });

    test('serializes empty date range as null for VPA-only search', () {
      const request = MerchantVpaTxnRequestModel(
        from: '',
        to: '',
        creditVpa: 'hardwarisweets.anet@axisbank',
      );

      expect(request.toJson(), {
        'from': null,
        'to': null,
        'creditVpa': 'hardwarisweets.anet@axisbank',
      });
    });
  });

  group('MerchantVpaTxnResponseModel', () {
    test('parses transaction data used by VPA history and invoice', () {
      final response = MerchantVpaTxnResponseModel.fromJson({
        'successMessage': 'Success',
        'statusCode': 200,
        'totalAmount': '830.00',
        'monthlyupiTxnAmount': {
          'June': 100.0,
          'July': 730.0,
        },
        'pageData': {
          'content': [
            {
              'refId': '023060385758',
              'name': 'Amit Sharma',
              'status': 'SUCCESS',
              'transactionAmount': '100.00',
              'transactionType': 'UPI',
              'accountDetailsAccType': 'SAVINGS',
              'code': '356',
              'customerVpa': '965008427@ybl',
              'creditVpa': 'hardwarisweets.anet@axisbank',
              'rrn': '023060385758',
              'deviceId': 'HS280CN3000000341',
              'merchantId': 'ALLIANCE10118254',
              'addedOn': '2025-08-26T12:32:43.513',
            },
          ],
          'first': true,
          'last': true,
          'empty': false,
          'number': 0,
          'size': 10,
          'totalPages': 1,
          'totalElements': 1,
        },
      });

      expect(response.statusCode, 200);
      expect(response.totalAmount, 830);
      expect(response.monthlyUpiTxnAmount['June'], 100);
      expect(response.monthlyUpiTxnAmount['July'], 730);
      expect(response.pageData.content, hasLength(1));

      final txn = response.pageData.content.single;
      expect(txn.refId, '023060385758');
      expect(txn.transactionAmount, '100.00');
      expect(txn.accountDetailsAccType, 'SAVINGS');
      expect(txn.creditVpa, 'hardwarisweets.anet@axisbank');
      expect(txn.merchantId, 'ALLIANCE10118254');
    });
  });

  group('PosTerminalResponseModel', () {
    test('parses terminal list as strings', () {
      final response = PosTerminalResponseModel.fromJson({
        'content': [51169086, '51169087'],
        'first': true,
        'last': true,
        'number': 0,
        'size': 10,
        'totalPages': 1,
        'totalElements': 2,
      });

      expect(response.content, ['51169086', '51169087']);
      expect(response.totalElements, 2);
    });
  });

  group('PosTxnHistoryResponseModel', () {
    test('parses POS transaction data used by history and invoice', () {
      final response = PosTxnHistoryResponseModel.fromJson({
        'totalAmount': 90878.11,
        'count': 75,
        'monthlyValues': {
          'June': 0.0,
          'July': 905.0,
          'August': 30760.0,
        },
        'sumEmiMdrValues': {
          'June': 0.0,
          'July': 10.5,
          'August': 250.25,
        },
        'responsePage': {
          'content': [
            {
              'merchantId': '651010000022371',
              'terminalId': '51169086',
              'transactionDate': '07/08/2025',
              'transactionTime': '12:07:22',
              'rrn': '004412014998',
              'amount': '760.00',
              'authCode': 'F05211',
              'acquirerId': 'OMAIND',
              'batchNo': '036',
              'cardNo': '517252******3587',
              'currency': '356',
              'nameOnCard': 'PRANAV PANKAJ',
              'posEntryMode': '051',
              'responseCode': '000',
              'responseDesc': 'SUCCESS',
              'schemeName': 'MASTER',
              'stan': '000227',
              'terminalAddress': 'HARDWARI SWEETS MILK ADELHI DL IN',
              'transactionType': 'OSAL001',
              'insertDateTime': '07/08/2025 12:07:25',
              'settled': true,
            },
          ],
          'first': true,
          'last': false,
          'empty': false,
          'number': 0,
          'size': 10,
          'totalPages': 75,
          'totalElements': 75,
        },
      });

      expect(response.count, 75);
      expect(response.totalAmount, 90878.11);
      expect(response.monthlyValues['August'], 30760.0);
      expect(response.sumEmiMdrValues['August'], 250.25);
      expect(response.responsePage.totalElements, 75);

      final txn = response.responsePage.content.single;
      expect(txn.merchantId, '651010000022371');
      expect(txn.terminalId, '51169086');
      expect(txn.amount, '760.00');
      expect(txn.authCode, 'F05211');
      expect(txn.settled, isTrue);
    });

    test('uses responsePage totalElements when count is missing', () {
      final response = PosTxnHistoryResponseModel.fromJson({
        'totalAmount': '1200.50',
        'responsePage': {
          'content': const [],
          'first': true,
          'last': true,
          'empty': true,
          'number': 0,
          'size': 10,
          'totalPages': 1,
          'totalElements': 12,
        },
      });

      expect(response.count, 12);
      expect(response.totalAmount, 1200.50);
    });

    test('aggregates by-MID list responses into one history response', () {
      final response = PosTxnHistoryResponseModel.fromDynamic([
        {
          'serialId': '9222625864',
          'totalAmount': 100.0,
          'count': 1,
          'monthlyValues': {
            'June': 100.0,
          },
          'sumEmiMdrValues': {
            'June': 5.0,
          },
          'sendMailResponse': {
            'responseCode': '00',
            'responseMessage': 'Report sent',
          },
          'responsePage': {
            'content': [
              {
                'merchantId': '651010000022371',
                'terminalId': '51169086',
                'transactionDate': '01/06/2025',
                'transactionTime': '12:00:00',
                'rrn': '111',
                'amount': '100.00',
                'authCode': 'A1',
                'responseDesc': 'SUCCESS',
              },
            ],
            'first': true,
            'last': true,
            'empty': false,
            'number': 0,
            'size': 10,
            'totalPages': 1,
            'totalElements': 1,
          },
        },
        {
          'serialId': '9222625863',
          'totalAmount': 250.0,
          'count': 2,
          'monthlyValues': {
            'June': 50.0,
            'July': 200.0,
          },
          'sumEmiMdrValues': {
            'July': 12.5,
          },
          'responsePage': {
            'content': [
              {
                'merchantId': '651010000022372',
                'terminalId': '51169087',
                'transactionDate': '02/07/2025',
                'transactionTime': '13:00:00',
                'rrn': '222',
                'amount': '250.00',
                'authCode': 'A2',
                'responseDesc': 'SUCCESS',
              },
            ],
            'first': true,
            'last': true,
            'empty': false,
            'number': 0,
            'size': 10,
            'totalPages': 1,
            'totalElements': 2,
          },
        },
      ]);

      expect(response.count, 3);
      expect(response.totalAmount, 350);
      expect(response.responsePage.content, hasLength(2));
      expect(response.monthlyValues['June'], 150);
      expect(response.monthlyValues['July'], 200);
      expect(response.sumEmiMdrValues['June'], 5);
      expect(response.sumEmiMdrValues['July'], 12.5);
      expect(response.sendMailResponse.isSuccess, isTrue);
      expect(response.terminalSummaries, hasLength(2));
      expect(response.terminalSummaries.first.serialNumber, '9222625864');
      expect(response.terminalSummaries.first.count, 1);
      expect(response.terminalSummaries.last.totalAmount, 250);
    });
  });

  group('SettlementHistoryResponseModel', () {
    test('parses aggregate page number from nested pageable data', () {
      final response = SettlementHistoryResponseModel.fromJson({
        'settlementAggregatePage': {
          'content': [
            {
              'tranDate': '2025-08-02',
              'grossTransactionAmount': 30000.00,
              'transactionCount': 1,
              'utr': 'AXISP00697919374',
              'gst': 91.80,
              'mdrAmount': 510.00,
              'totalAmountPayable': 29398.20,
              'rrn': '521422850958',
              'approveCode': '094520',
              'mid': '651010000022371',
              'merPayDone': true,
              'misDone': true,
              'reconciled': true,
            },
          ],
          'first': false,
          'last': false,
          'empty': false,
          'number': 0,
          'size': 10,
          'totalPages': 3,
          'totalElements': 25,
          'pageable': {
            'pageNumber': 1,
          },
        },
        'settlementTotal': {
          'totalAmount': 88756.93,
          'transactionCount': 88,
          'settlementCount': 23,
        },
        'settledSummaryPage': {
          'content': const [],
        },
      });

      expect(response.settlementAggregatePage.number, 1);
      expect(response.settlementAggregatePage.totalPages, 3);
      expect(response.settlementTotal.settlementCount, 23);

      final settlement = response.settlementAggregatePage.content.single;
      expect(settlement.mid, '651010000022371');
      expect(settlement.rrn, '521422850958');
      expect(settlement.approveCode, '094520');
      expect(settlement.merPayDone, isTrue);
      expect(settlement.misDone, isTrue);
      expect(settlement.reconciled, isTrue);
    });
  });
}

