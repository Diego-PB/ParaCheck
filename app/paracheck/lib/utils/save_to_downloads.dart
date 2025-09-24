import 'dart:typed_data';

// Choisit l'implémentation automatiquement selon la plateforme.
import 'save_to_downloads_io.dart'
    if (dart.library.html) 'save_to_downloads_web.dart';

/// Sauvegarde `bytes` sous `filename` dans le dossier Télécharger / Downloads.
/// Retourne un chemin *si connu* (desktop), sinon null (Android/Web).
Future<String?> saveToDownloads(
  Uint8List bytes,
  String filename, {
  String mimeType = 'application/octet-stream',
}) {
  return saveToDownloadsImpl(bytes, filename, mimeType: mimeType);
}
