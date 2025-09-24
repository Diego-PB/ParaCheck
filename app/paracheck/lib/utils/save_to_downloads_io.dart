import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> saveToDownloadsImpl(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/json',
}) async {
  if (Platform.isAndroid) {
    const ch = MethodChannel('paracheck/files');
    final uri = await ch.invokeMethod<String>('saveToDownloads', {
      'filename': filename,
      'mime': mimeType,
      'bytes': bytes,
    });
    // Android renvoie souvent un content:// (pas de chemin absolu exploitable)
    return uri; // utile pour logs
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final dir = await getDownloadsDirectory();
    final path = '${dir!.path}/$filename';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  // iOS/autres: documents app
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$filename';
  await File(path).writeAsBytes(bytes);
  return path;
}
