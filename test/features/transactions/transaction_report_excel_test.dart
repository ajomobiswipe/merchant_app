import 'dart:convert';

import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/transactions/utils/transaction_report_excel.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String sheetXml(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final file = archive.findFile('xl/worksheets/sheet1.xml');
    expect(file, isNotNull);
    return utf8.decode(file!.content as List<int>);
  }

  group('TransactionReportExcel', () {
    test('writes VPA transaction rows using API fields', () {
      const transaction = MerchantVpaTransactionModel(
        refId: 'REF-1',
        name: 'Store',
        status: 'SUCCESS',
        transactionAmount: '125.50',
        transactionType: 'CREDIT',
        accountDetailsAccType: 'SAVINGS',
        code: '00',
        payerName: 'Asha',
        payeeName: 'ANET',
        customerVpa: 'asha@okaxis',
        creditVpa: 'store@anet',
        rrn: '123456',
        deviceId: 'SB-1',
        merchantId: 'MID1',
        addedOn: '22-09-2026 10:15:00',
      );

      final xml = sheetXml(
        TransactionReportExcel.fromVpaTransactions([transaction]),
      );

      expect(xml, contains('Date/Time'));
      expect(xml, contains('22-09-2026 10:15:00'));
      expect(xml, contains('125.50'));
      expect(xml, contains('Asha'));
      expect(xml, contains('123456'));
      expect(xml, contains('REF-1'));
    });

    test('writes POS rows in the backend TransactionHistoryReport column order',
        () {
      const transaction = PosTransactionModel(
        merchantId: '651010000022371',
        terminalId: '51169086',
        transactionDate: '07/08/2025',
        transactionTime: '12:07:22',
        rrn: '004412014998',
        amount: '760.00',
        authCode: 'F05211',
        acquirerId: 'OMAIND',
        batchNo: '036',
        cardNo: '517252******3587',
        currency: '356',
        nameOnCard: 'PRANAV PANKAJ',
        posEntryMode: '051',
        responseCode: '000',
        responseDesc: 'SUCCESS',
        schemeName: 'MASTER',
        stan: '000227',
        terminalAddress: 'HARDWARI SWEETS MILK ADELHI DL IN',
        transactionType: 'OSAL001',
        insertDateTime: '07/08/2025 12:07:25',
        settled: true,
        mti: '1210',
        processCode: '000000',
        isVoided: false,
        isReverse: false,
        traceNumber: '000227',
        acquiringBin: 'OMAIND',
        de7: '0807063715',
        settledOn: '08/08/2025 10:14:47',
        mcc: '5814',
        deviceType: 'ANDROID POS',
        txnSource: 'CARD',
        terminalLocation: 'HARDWARI SWEETS MILK ADELHI        DL IN',
      );

      final bytes = TransactionReportExcel.fromPosTransactions([transaction]);
      final xml = sheetXml(bytes);
      final workbook = ZipDecoder().decodeBytes(bytes);
      final workbookXml = utf8.decode(
        workbook.findFile('xl/workbook.xml')!.content as List<int>,
      );

      expect(workbookXml, contains('Transaction History'));
      expect(xml, contains('AcquirerID'));
      expect(xml, contains('TerminalLocation'));
      expect(xml, contains('isVoided'));
      expect(xml, contains('TxnSource'));
      expect(xml, contains('OSAL001'));
      expect(xml, contains('1210'));
      expect(xml, contains('0807063715'));
      expect(xml, contains('ANDROID POS'));
      expect(xml, contains('CARD'));
      expect(xml, contains('false'));
      expect(xml, contains('true'));
      expect(TransactionReportExcel.posHeaders, hasLength(33));
    });

    test('writes settlement rows in the backend report column order', () {
      final settlement = SettlementItemModel(
        tranDate: DateTime(2025, 8, 2),
        utr: 'AXISP00697919374',
        transactionCount: 1,
        grossTransactionAmount: 30000,
        totalAmountPayable: 29398.20,
        gst: 91.80,
        mdrAmount: 510,
        rrn: '521422850958',
        approveCode: '094520',
        mid: '651010000022371',
        merchantTxnIdAuthId: 'AUTH-1',
        merPayDone: true,
        misDone: true,
        reconciled: true,
      );

      final bytes = TransactionReportExcel.fromSettlements([settlement]);
      final xml = sheetXml(bytes);
      final workbook = ZipDecoder().decodeBytes(bytes);
      final workbookXml = utf8.decode(
        workbook.findFile('xl/workbook.xml')!.content as List<int>,
      );

      expect(workbookXml, contains('Settlement History Report'));
      expect(xml, contains('MerchantTxnIdAuthId'));
      expect(xml, contains('TotalAmountPayable'));
      expect(xml, contains('AXISP00697919374'));
      expect(xml, contains('AUTH-1'));
      expect(xml, contains('29398.20'));
      expect(TransactionReportExcel.settlementHeaders, hasLength(13));
    });
  });
}
