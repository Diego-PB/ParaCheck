import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:paracheck/utils/save_to_downloads.dart';
import 'package:paracheck/utils/prefs_export_import.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/widgets/section_title.dart';
import 'package:paracheck/widgets/app_notice.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/pages/manage_sites.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _clearBefore = false;
  String? _lastMessage;

  // EXPORT -> Téléchargements (Android/Desktop) ou téléchargement direct (Web)
  Future<void> _exportToDownloads() async {
    try {
      final fname =
          'paracheck-prefs-${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
      final Uint8List bytes = await PrefsExportImport.exportAsBytes();

      final savedPath = await saveToDownloads(
        bytes,
        fname,
        mimeType: 'application/json',
      );

      setState(
        () =>
            _lastMessage =
                savedPath == null
                    ? "Export enregistré dans Téléchargements."
                    : "Export enregistré :\n$savedPath",
      );
    } catch (e) {
      setState(() => _lastMessage = "Échec de l'export : $e");
    }
  }

  // IMPORT -> l’utilisateur choisit un .json (depuis Téléchargements par ex.)
  Future<void> _importFromFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // nécessaire pour le Web
      );
      if (res == null) return;

      final file = res.files.single;
      final bytes =
          file.bytes ?? await File(file.path!).readAsBytes(); // Desktop/Android

      final n = await PrefsExportImport.importFromBytes(
        bytes,
        clearBefore: _clearBefore,
      );
      setState(() => _lastMessage = "Import réussi : $n clé(s) écrite(s).");
    } catch (e) {
      setState(() => _lastMessage = "Échec de l'import : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paramètres',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionTitle('Sites de vol'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gérez votre liste de sites enregistrés.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              PrimaryButton(
                label: 'Gérer les sites',
                icon: Icons.place,
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageSitesPage(),
                      ),
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionTitle('Sauvegarde & transfert (fichier .json)'),
          const SizedBox(height: AppSpacing.md),
          const AppNotice(
            kind: NoticeKind.attention,
            title: 'Export / Import',
            message:
                "Exportez vos données locales (SharedPreferences) dans un fichier .json, puis ré-importez ce fichier depuis votre appareil. Compatible Android, Desktop et Web.",
          ),
          if (_lastMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppNotice(
              kind:
                  _lastMessage!.startsWith("Échec")
                      ? NoticeKind.warning
                      : NoticeKind.valid,
              title: _lastMessage!.startsWith("Échec") ? "Erreur" : "Info",
              message: _lastMessage!,
              outlined: true,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              PrimaryButton(
                label: 'Exporter vers un fichier',
                icon: Icons.download,
                onPressed: _exportToDownloads,
              ),
              SecondaryButton(
                label: 'Importer depuis un fichier',
                onPressed: _importFromFile,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Switch(
                value: _clearBefore,
                onChanged: (v) => setState(() => _clearBefore = v),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  "Remplacer tout lors de l'import (sinon, les données existantes sont conservées)",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
