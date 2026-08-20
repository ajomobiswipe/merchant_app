import 'dart:async';
import 'dart:html' as html;

Future<void> downloadInvoicePdf({
  required List<int> bytes,
  required String filename,
}) async {
  final blob = html.Blob(<Object>[bytes], 'application/pdf');
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: objectUrl)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();

  // Let the browser consume the object URL before freeing the in-memory PDF.
  await Future<void>.delayed(const Duration(milliseconds: 100));
  html.Url.revokeObjectUrl(objectUrl);
}
