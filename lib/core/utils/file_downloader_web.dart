import 'dart:async';
import 'dart:html' as html;

Future<void> downloadFile({
  required List<int> bytes,
  required String filename,
  String mimeType = 'application/octet-stream',
}) async {
  final blob = html.Blob(<Object>[bytes], mimeType);
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: objectUrl)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();

  await Future<void>.delayed(const Duration(milliseconds: 100));
  html.Url.revokeObjectUrl(objectUrl);
}
