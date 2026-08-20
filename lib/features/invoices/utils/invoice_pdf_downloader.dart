import 'invoice_pdf_downloader_stub.dart'
    if (dart.library.html) 'invoice_pdf_downloader_web.dart'
    if (dart.library.io) 'invoice_pdf_downloader_io.dart' as platform;

/// Saves a generated invoice PDF in a way that suits the current platform.
///
/// Browsers receive a native file download, while Android and iOS retain the
/// existing behaviour of opening the locally saved PDF.
Future<void> downloadInvoicePdf({
  required List<int> bytes,
  required String filename,
}) {
  return platform.downloadInvoicePdf(
    bytes: bytes,
    filename: _safePdfFilename(filename),
  );
}

String _safePdfFilename(String value) {
  final withoutExtension =
      value.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), '');
  final cleaned = withoutExtension
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  return '${cleaned.isEmpty ? 'anet_invoice' : cleaned}.pdf';
}
