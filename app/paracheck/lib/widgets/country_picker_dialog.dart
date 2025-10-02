import 'package:flutter/material.dart';

// Dialog to pick a country from a list
const Map<String, String> iso2ToName = {
  'FR': 'France',
  'ES': 'Espagne',
  'IT': 'Italie',
  'DE': 'Allemagne',
  'CH': 'Suisse',
  'BE': 'Belgique',
  'PT': 'Portugal',
  'GB': 'Royaume-Uni',
  'MA': 'Maroc',
  'TN': 'Tunisie',
  'DZ': 'Algérie',
  // Add more countries as needed
};

// Show a dialog to pick countries, returns list of selected ISO2 codes or null if cancelled
Future<List<String>?> showCountryPickerDialog(
  BuildContext context, {
  List<String> preSelected = const [],
}) {
  final selected = {...preSelected};
  final ctrl = TextEditingController();
  String query = '';

  List<MapEntry<String, String>> filtered() {
    final all =
        iso2ToName.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    if (query.isEmpty) return all;
    final q = query.toLowerCase();

    return all
        .where(
          (e) =>
              e.value.toLowerCase().contains(q) ||
              e.key.toLowerCase().contains(q),
        )
        .toList();
  }

  return showDialog<List<String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => AlertDialog(
              title: const Text('Sélectionner les pays'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ctrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Rechercher un pays ou code (ex: FR)...',
                      ),
                      onChanged:
                          (v) => setState(() {
                            query = v;
                          }),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Scrollbar(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final e in filtered())
                              CheckboxListTile(
                                dense: true,
                                value: selected.contains(e.key),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      selected.add(e.key);
                                    } else {
                                      selected.remove(e.key);
                                    }
                                  });
                                },
                                title: Text(e.value),
                                subtitle: Text(e.key),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Importer'),
                  onPressed:
                      selected.isEmpty
                          ? null
                          : () {
                            Navigator.of(
                              context,
                            ).pop(selected.toList()..sort());
                          },
                ),
              ],
            ),
      );
    },
  );
}
