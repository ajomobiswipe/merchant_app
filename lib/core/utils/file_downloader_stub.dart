Future<void> downloadFile({
  required List<int> bytes,
  required String filename,
  String mimeType = 'application/octet-stream',
}) {
  throw UnsupportedError('File downloads are not supported on this platform.');
}
