import 'dart:typed_data';
import 'dart:js_interop';                // <-- pour .toJS
import 'package:web/web.dart' as web;

Future<String?> saveToDownloadsImpl(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/json',
}) async {
  // Convertit Uint8List -> JS Uint8Array, puis List -> JSArray<BlobPart>
  final parts = <web.BlobPart>[bytes.toJS].toJS;

  final blob = web.Blob(
    parts,
    web.BlobPropertyBag(type: mimeType),
  );

  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';

  (web.document.body ?? web.document.documentElement)!.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);

  return null; // chemin inconnu côté navigateur
}
