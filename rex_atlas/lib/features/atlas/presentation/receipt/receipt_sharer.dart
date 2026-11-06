import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Hands a finished receipt file to the device's share sheet.
///
/// Kept behind an interface so tests (and other platforms) can swap it.
abstract class ReceiptSharer {
  Future<void> shareImage(Uint8List png, String fileName);
  Future<void> sharePdf(Uint8List pdf, String fileName);
}

/// Opens the system share sheet (WhatsApp, Mail, Files, …). On the web it
/// falls back to a download.
class DeviceReceiptSharer implements ReceiptSharer {
  const DeviceReceiptSharer();

  static const _subject = 'Rex transaction receipt (demo)';

  @override
  Future<void> shareImage(Uint8List png, String fileName) =>
      _share(png, fileName, 'image/png');

  @override
  Future<void> sharePdf(Uint8List pdf, String fileName) =>
      _share(pdf, fileName, 'application/pdf');

  Future<void> _share(Uint8List bytes, String name, String mime) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mime, name: name)],
        fileNameOverrides: [name],
        subject: _subject,
        title: _subject,
      ),
    );
  }
}
