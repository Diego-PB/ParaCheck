import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/models/flight.dart';
import 'package:paracheck/pages/manage_sites.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/utils/pdf_export_helper.dart';
import 'package:paracheck/utils/prefs_export_import.dart';
import 'package:paracheck/utils/save_to_downloads.dart';

import 'package:paracheck/widgets/app_notice.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/primary_button.dart';
import 'package:paracheck/widgets/secondary_button.dart';
import 'package:paracheck/widgets/section_title.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- Données vols (pour export PDF) ---
  final _flightRepository = SharedPrefsFlightRepository();
  List<Flight> _flights = [];
  bool _loadingFlights = true;
  String? _flightsError;

  // --- Export/Import préférences ---
  bool _clearBefore = false;
  String? _lastMessage; // feedback utilisateur (export/import)

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    try {
      final flights = await _flightRepository.getAll();
      setState(() {
        _flights = flights;
        _loadingFlights = false;
      });
    } catch (e) {
      setState(() {
        _flightsError = e.toString();
        _loadingFlights = false;
      });
    }
  }

  // EXPORT préférences -> Téléchargements (Android/Desktop) ou download (Web)
  Future<void> _exportPrefsToDownloads() async {
    try {
      final fname =
          'paracheck-prefs-${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
      final bytes = await PrefsExportImport.exportAsBytes();

      final savedPath = await saveToDownloads(
        bytes,
        fname,
        mimeType: 'application/json',
      );

      setState(() {
        _lastMessage = savedPath == null
            ? "Export enregistré dans Téléchargements."
            : "Export enregistré :\n$savedPath";
      });
    } catch (e) {
      setState(() => _lastMessage = "Échec de l'export : $e");
    }
  }

  // IMPORT préférences -> l’utilisateur choisit un .json (depuis Téléchargements, etc.)
  Future<void> _importPrefsFromFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // important pour le Web et simple à gérer cross-plateforme
      );
      if (res == null) return;

      final file = res.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        // Cas rarissime si withData est ignoré par la plateforme/permission.
        setState(() => _lastMessage =
            "Échec de l'import : impossible de lire le fichier. Réessayez ou vérifiez les permissions.");
        return;
      }

      final n = await PrefsExportImport.importFromBytes(
        bytes,
        clearBefore: _clearBefore,
      );
      setState(() => _lastMessage = "Import réussi : $n clé(s) écrite(s).");
    } catch (e) {
      setState(() => _lastMessage = "Échec de l'import : $e");
    }
  }

  // EXPORT PDF des vols
  Future<void> _exportFlightsPdf() async {
    try {
      await exportFlightsPdf(_flights);
    } catch (e) {
      setState(() => _lastMessage = "Échec de l'export PDF : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paramètres',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ----- Gestion des sites -----
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageSitesPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ----- Export PDF des vols -----
          const SectionTitle('Exporter mes vols (PDF)'),
          const SizedBox(height: AppSpacing.md),
          if (_loadingFlights) ...[
            const Center(child: CircularProgressIndicator()),
          ] else if (_flightsError != null) ...[
            AppNotice(
              kind: NoticeKind.warning,
              title: 'Erreur',
              message: _flightsError!,
              outlined: true,
            ),
          ] else ...[
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                PrimaryButton(
                  label: 'Exporter en PDF',
                  icon: Icons.picture_as_pdf,
                  onPressed: _flights.isEmpty ? null : _exportFlightsPdf,
                ),
                if (_flights.isEmpty)
                  const AppNotice(
                    kind: NoticeKind.attention,
                    title: 'Aucun vol',
                    message:
                        "Ajoutez des vols pour activer l'export PDF.",
                    outlined: true,
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ----- Sauvegarde & transfert (JSON) -----
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
              kind: _lastMessage!.startsWith("Échec")
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
                onPressed: _exportPrefsToDownloads,
              ),
              SecondaryButton(
                label: 'Importer depuis un fichier',
                onPressed: _importPrefsFromFile,
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
                  "Remplacer tout lors de l'import (sinon, les données existantes sont conservées).",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
