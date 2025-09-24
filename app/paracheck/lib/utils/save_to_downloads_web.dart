// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> saveToDownloadsImpl(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/json',
}) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor =
      html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  // Sur le Web, on ne connaît pas le chemin exact (c’est le dossier de téléchargements du navigateur).
  return null;
}
