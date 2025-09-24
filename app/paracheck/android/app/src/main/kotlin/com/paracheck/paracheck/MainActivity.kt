package com.paracheck.paracheck

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
  private val CHANNEL = "paracheck/files"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "saveToDownloads" -> {
            val filename = call.argument<String>("filename")
            val mime = call.argument<String>("mime") ?: "application/json"
            val bytes = call.argument<ByteArray>("bytes")

            if (filename == null || bytes == null) {
              result.error("ARG", "filename/bytes manquants", null)
              return@setMethodCallHandler
            }

            try {
              val uri = saveToDownloads(this, filename, mime, bytes)
              result.success(uri.toString())  // content://… (Q+) ou file://…
            } catch (e: Exception) {
              result.error("IO", e.message, null)
            }
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun saveToDownloads(
    context: Context,
    filename: String,
    mime: String,
    bytes: ByteArray
  ): Uri {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      // Android 10+ : MediaStore (scoped storage)
      val values = ContentValues().apply {
        put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
        put(MediaStore.MediaColumns.MIME_TYPE, mime)
        put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
        put(MediaStore.MediaColumns.IS_PENDING, 1)
      }
      val resolver = context.contentResolver
      val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
      val uri = resolver.insert(collection, values) ?: throw IOException("Insert MediaStore KO")
      resolver.openOutputStream(uri)?.use { it.write(bytes) }
        ?: throw IOException("OpenOutputStream KO")
      values.clear()
      values.put(MediaStore.MediaColumns.IS_PENDING, 0)
      resolver.update(uri, values, null, null)
      uri
    } else {
      // < Android 10 : accès direct au dossier public Download
      val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
      if (!dir.exists()) dir.mkdirs()
      val file = File(dir, filename)
      FileOutputStream(file).use { it.write(bytes) }
      // rafraîchir l'index média pour qu'il apparaisse tout de suite
      MediaScannerConnection.scanFile(context, arrayOf(file.absolutePath), arrayOf(mime), null)
      Uri.fromFile(file)
    }
  }
}
