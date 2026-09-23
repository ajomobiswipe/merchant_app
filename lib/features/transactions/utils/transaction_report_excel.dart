import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';

const xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

class TransactionReportExcel {
  static const String sheetName = 'Transactions';
  static const String posSheetName = 'Transaction History';
  static const String settlementSheetName = 'Settlement History Report';
  static const List<String> settlementHeaders = [
    'RRN',
    'ApproveCode',
    'TranDate',
    'MerPayDone',
    'MisDone',
    'MerchantTxnIdAuthId',
    'Mid',
    'UTR',
    'TotalAmountPayable',
    'GST',
    'MdrAmount',
    'GrossTransactionAmount',
    'IsReconciled',
  ];
  static const List<String> posHeaders = [
    'AcquirerID',
    'MerchantID',
    'TerminalID',
    'RRN',
    'Amount',
    'transactionType',
    'MTI',
    'Currency',
    'BatchNo',
    'AuthCode',
    'TerminalLocation',
    'ProcessCode',
    'isVoided',
    'IsReverse',
    'TraceNumber',
    'responseCode',
    'CardNo',
    'AcquiringBIN',
    'DE_7',
    'transactionTime',
    'transactionDate',
    'isSettled',
    'SettledOn',
    'isBatchClosed',
    'BatchClosedOn',
    'NameOnCard',
    'STAN',
    'ResponseDesc',
    'MCC',
    'schemeName',
    'posEntryMode',
    'DeviceType',
    'TxnSource',
  ];

  static List<int> fromVpaTransactions(
    List<MerchantVpaTransactionModel> transactions,
  ) {
    return _encode(
      sheetName: sheetName,
      headers: const [
        'Date/Time',
        'Amount',
        'Customer Name',
        'Customer VPA',
        'Credit VPA',
        'RRN',
        'Ref ID',
        'Status',
        'Transaction Type',
        'Merchant ID',
      ],
      rows: transactions
          .map(
            (transaction) => [
              transaction.addedOn,
              transaction.transactionAmount,
              transaction.payerName,
              transaction.customerVpa,
              transaction.creditVpa,
              transaction.rrn,
              transaction.refId,
              transaction.status,
              transaction.transactionType,
              transaction.merchantId,
            ],
          )
          .toList(),
    );
  }

  static List<int> fromPosTransactions(
    List<PosTransactionModel> transactions,
  ) {
    return _encode(
      sheetName: posSheetName,
      headers: posHeaders,
      rows: transactions.map(_posRow).toList(),
    );
  }

  static List<int> fromSettlements(List<SettlementItemModel> settlements) {
    return _encode(
      sheetName: settlementSheetName,
      headers: settlementHeaders,
      rows: settlements.map(_settlementRow).toList(),
    );
  }

  static List<String> _settlementRow(SettlementItemModel settlement) {
    return [
      settlement.rrn,
      settlement.approveCode,
      settlement.tranDate == null
          ? ''
          : settlement.tranDate!.toIso8601String().split('T').first,
      '${settlement.merPayDone}',
      '${settlement.misDone}',
      settlement.merchantTxnIdAuthId,
      settlement.mid,
      settlement.utr,
      settlement.totalAmountPayable.toStringAsFixed(2),
      settlement.gst.toStringAsFixed(2),
      settlement.mdrAmount.toStringAsFixed(2),
      settlement.grossTransactionAmount.toStringAsFixed(2),
      '${settlement.reconciled}',
    ];
  }

  static List<String> _posRow(PosTransactionModel transaction) {
    final location = transaction.terminalLocation.isNotEmpty
        ? transaction.terminalLocation
        : transaction.terminalAddress;
    return [
      transaction.acquirerId,
      transaction.merchantId,
      transaction.terminalId,
      transaction.rrn,
      transaction.amount,
      transaction.transactionType,
      transaction.mti,
      transaction.currency,
      transaction.batchNo,
      transaction.authCode,
      location,
      transaction.processCode,
      '${transaction.isVoided}',
      '${transaction.isReverse}',
      transaction.traceNumber,
      transaction.responseCode,
      transaction.cardNo,
      transaction.acquiringBin,
      transaction.de7,
      transaction.transactionTime,
      transaction.transactionDate,
      '${transaction.settled}',
      transaction.settledOn,
      '${transaction.isBatchClosed}',
      transaction.batchClosedOn,
      transaction.nameOnCard,
      transaction.stan,
      transaction.responseDesc,
      transaction.mcc,
      transaction.schemeName,
      transaction.posEntryMode,
      transaction.deviceType,
      transaction.txnSource,
    ];
  }

  static List<int> _encode({
    required String sheetName,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final sheetXml = _worksheetXml([headers, ...rows]);
    final archive = Archive()
      ..addFile(_xmlFile('[Content_Types].xml', _contentTypesXml))
      ..addFile(_xmlFile('_rels/.rels', _relsXml))
      ..addFile(_xmlFile('xl/workbook.xml', _workbookXml(sheetName)))
      ..addFile(_xmlFile('xl/_rels/workbook.xml.rels', _workbookRelsXml))
      ..addFile(_xmlFile('xl/worksheets/sheet1.xml', sheetXml));

    return ZipEncoder().encode(archive);
  }

  static ArchiveFile _xmlFile(String name, String xml) {
    final bytes = utf8.encode(xml);
    return ArchiveFile(name, bytes.length, bytes);
  }

  static String _worksheetXml(List<List<String>> rows) {
    final buffer = StringBuffer()
      ..write(
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<sheetData>',
      );

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      buffer.write('<row r="${rowIndex + 1}">');
      final row = rows[rowIndex];
      for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
        final cellRef = '${_columnName(columnIndex)}${rowIndex + 1}';
        buffer
          ..write('<c r="$cellRef" t="inlineStr"><is><t>')
          ..write(_escapeXml(row[columnIndex]))
          ..write('</t></is></c>');
      }
      buffer.write('</row>');
    }

    buffer.write('</sheetData></worksheet>');
    return buffer.toString();
  }

  static String _columnName(int index) {
    var n = index;
    final letters = StringBuffer();
    do {
      letters.writeCharCode(65 + (n % 26));
      n = (n ~/ 26) - 1;
    } while (n >= 0);
    return letters.toString().split('').reversed.join();
  }

  static String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  static const _contentTypesXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
      '</Types>';

  static const _relsXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
      '</Relationships>';

  static String _workbookXml(String name) {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets><sheet name="${_escapeXml(name)}" sheetId="1" r:id="rId1"/></sheets>'
        '</workbook>';
  }

  static const _workbookRelsXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
      '</Relationships>';

}
