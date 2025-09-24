import 'dart:io';
import 'package:flutter/material.dart';
import 'package:paracheck/models/flights.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int get totalAltitude => _flights.fold(0, (sum, f) => sum + (f.altitude));
  int get maxAltitudeValue => _flights.isEmpty ? 0 : _flights.map((f) => f.altitude).reduce((a, b) => a > b ? a : b);
  final _flightRepository = SharedPrefsFlightRepository();

  List<Flight> _flights = [];
  bool _loading = true;
  String? _error;

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
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // --- Statistiques pour l'export PDF ---
  int get totalFlights => _flights.length;
  Duration get totalDuration =>
      _flights.fold(Duration.zero, (d, f) => d + f.duration);
  int get maxDurationMinutes =>
      _flights.isEmpty
          ? 0
          : _flights
              .map((f) => f.duration.inMinutes)
              .reduce((a, b) => a > b ? a : b);
  int get maxAltitude =>
      _flights.isEmpty
          ? 0
          : _flights.map((f) => f.altitude).reduce((a, b) => a > b ? a : b);
  Set<String> get uniqueSites =>
      _flights.map((f) => f.site).where((s) => s.isNotEmpty).toSet();
  int get totalSites => uniqueSites.length;

  Map<int, List<Flight>> get flightsByYear {
    final map = <int, List<Flight>>{};
    for (final f in _flights) {
      map.putIfAbsent(f.date.year, () => []).add(f);
    }
    return map;
  }

  Map<int, Map<int, List<Flight>>> get flightsByYearMonth {
    final map = <int, Map<int, List<Flight>>>{};
    for (final f in _flights) {
      map.putIfAbsent(f.date.year, () => {});
      map[f.date.year]!.putIfAbsent(f.date.month, () => []).add(f);
    }
    return map;
  }

  void _exportPdf() async {
    final pdf = pw.Document();

    String formatDuration(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h${m.toString().padLeft(2, '0')}m';
    }

    // --- Données pour graphiques ---
    final yearData = flightsByYear.entries.toList();
    final yearColors = [
      PdfColors.blue,
      PdfColors.red,
      PdfColors.orange,
      PdfColors.green,
      PdfColors.purple,
    ];
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    final years = yearData.map((e) => e.key).toList()..sort();
    // barData : pour chaque année, liste de 12 valeurs = altitude max d'un vol par mois
    final barData = <int, List<int>>{};
    for (final y in years) {
      final byMonth = List<int>.filled(12, 0);
      for (final f in flightsByYear[y] ?? []) {
        final m = f.date.month - 1;
        if (f.altitude > byMonth[m]) {
          byMonth[m] = f.altitude;
        }
      }
      barData[y] = byMonth;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Titre principal
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Performance', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('$totalSites visited flying sites', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Text('${totalFlights} flights', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ],
              ),
              pw.SizedBox(height: 12),
              // Nuage stats
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(32),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                margin: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Altitude', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                        pw.Row(children: [
                          pw.Text('Total ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('$totalAltitude', style: pw.TextStyle(fontSize: 18, color: PdfColors.red)),
                          pw.Text(' m'),
                        ]),
                        pw.Row(children: [
                          pw.Text('Max ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('$maxAltitudeValue', style: pw.TextStyle(fontSize: 16, color: PdfColors.red)),
                          pw.Text(' m'),
                        ]),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Flight time', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                        pw.Row(children: [
                          pw.Text('Total ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(formatDuration(totalDuration), style: pw.TextStyle(fontSize: 18, color: PdfColors.red)),
                        ]),
                        pw.Row(children: [
                          pw.Text('Max ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${maxDurationMinutes ~/ 60}h${(maxDurationMinutes % 60).toString().padLeft(2, '0')}m', style: pw.TextStyle(fontSize: 16, color: PdfColors.red)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              // Ligne camembert + légende
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Camembert visuel simple (barres circulaires proportionnelles)
                  pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      for (var i = 0; i < years.length; i++)
                        if ((flightsByYear[years[i]]?.length ?? 0) > 0)
                          pw.Container(
                            width: 80 - i * 14,
                            height: 80 - i * 14,
                            decoration: pw.BoxDecoration(
                              color: yearColors[i % yearColors.length],
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                    ],
                  ),
                  pw.SizedBox(width: 16),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < years.length; i++)
                        pw.Row(
                          children: [
                            pw.Container(width: 10, height: 10, color: yearColors[i % yearColors.length]),
                            pw.SizedBox(width: 4),
                            pw.Text('${years[i]} : ${flightsByYear[years[i]]?.length ?? 0} vols', style: pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              // Histogramme
              pw.Text('Altitude totale par mois', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              if (barData.isNotEmpty)
                pw.Container(
                  height: 140,
                  width: double.infinity,
                  child: pw.Builder(
                    builder: (context) {
                      final pageWidth = PdfPageFormat.a4.availableWidth - 16; // marges réduites
                      return pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Légende ordonnée
                          pw.Container(
                            width: 28,
                            height: 140,
                            child: pw.Stack(
                              children: [
                                for (var i = 1; i <= 3; i++)
                                  pw.Positioned(
                                    left: 0,
                                    bottom: (140.0 * (i * 1000) / 3000) - 8,
                                    child: pw.Text('${i} km', style: pw.TextStyle(fontSize: 9)),
                                  ),
                                // Graduation lines
                                for (var i = 1; i <= 3; i++)
                                  pw.Positioned(
                                    left: 20,
                                    right: 0,
                                    bottom: 140.0 * (i * 1000) / 3000,
                                    child: pw.Container(height: 1, color: PdfColors.grey400),
                                  ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 2),
                          // Histogramme
                          pw.Expanded(
                            child: _buildBarChart(
                              barData,
                              years,
                              months,
                              yearColors,
                              pageWidth - 30, // plus de place pour les barres
                              maxY: 3000,
                              barHeight: 120,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              pw.SizedBox(height: 16),
              pw.SizedBox(height: 16),
              pw.Text('Export generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    // Format du nom du fichier : donnees_JJ-MM-AAAA.pdf
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    final fileName = 'donnees_$dateStr.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  pw.Widget _buildBarChart(
    Map<int, List<int>> barData,
    List<int> years,
    List<String> months,
    List<PdfColor> colors,
    double width,
    {int maxY = 3000, int barHeight = 100}
  ) {
    final maxVal = maxY;
    final barGroupCount = 12;
    final groupWidth = width / barGroupCount;
    final barWidth = (groupWidth - 4) / (years.length > 0 ? years.length : 1);
    return pw.Stack(
      children: [
        // Bars
        for (var m = 0; m < 12; m++)
          for (var y = 0; y < years.length; y++)
            pw.Positioned(
              left: m * groupWidth + y * barWidth + 2,
              bottom: 16,
              child: pw.Container(
                width: barWidth,
                height: maxVal == 0 ? 0 : barHeight * (barData[years[y]]![m] / maxVal),
                color: colors[y % colors.length],
              ),
            ),
        // Month labels
        for (var m = 0; m < 12; m++)
          pw.Positioned(
            left: m * groupWidth,
            bottom: 0,
            child: pw.Container(
              width: groupWidth,
              alignment: pw.Alignment.center,
              child: pw.Text(months[m].substring(0, 3), style: pw.TextStyle(fontSize: 8)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paramètres',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Erreur : $_error'))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Exporter mes données :',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _exportPdf,
                          child: const Text('Exporter en PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
