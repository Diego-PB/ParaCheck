import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/flight.dart';

Future<void> exportFlightsPdf(List<Flight> flights) async {
  final pdf = pw.Document();

  // Statistiques principales
  int totalAltitude = flights.fold(0, (sum, f) => sum + (f.altitude));
  int maxAltitudeValue = flights.isEmpty ? 0 : flights.map((f) => f.altitude).reduce((a, b) => a > b ? a : b);
  int totalFlights = flights.length;
  Duration totalDuration = flights.fold(Duration.zero, (d, f) => d + f.duration);
  int maxDurationMinutes = flights.isEmpty ? 0 : flights.map((f) => f.duration.inMinutes).reduce((a, b) => a > b ? a : b);
  Set<String> uniqueSites = flights.map((f) => f.site).where((s) => s.isNotEmpty).toSet();
  int totalSites = uniqueSites.length;

  // Groupes pour graphiques
  final flightsByYear = <int, List<Flight>>{};
  for (final f in flights) {
    flightsByYear.putIfAbsent(f.date.year, () => []).add(f);
  }
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
  final maxFlightsPerYear = years.isEmpty ? 0 : years.map((y) => flightsByYear[y]!.length).reduce((a, b) => a > b ? a : b);

  // Données pour l'histogramme par mois
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

  // Formatage durée en texte
  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h${m.toString().padLeft(2, '0')}m';
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(16),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Titre principal et nombre de sites/vols
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Statistiques de vol', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('$totalSites sites de vol visités', style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                pw.Text('$totalFlights vols', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              ],
            ),
            pw.SizedBox(height: 12),

            // Bloc de statistiques globales
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
                  // Statistiques d'altitude
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Altitude', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                      pw.Row(children: [
                        pw.Text('Totale ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                  // Statistiques de durée de vol
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Durée de vol', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                      pw.Row(children: [
                        pw.Text('Totale ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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

            // Premier graphique : Altitude totale par mois
            pw.Text('Altitude maximale par mois', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                        // Axe des ordonnées (graduations)
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
                              // Lignes de graduation
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
                        // Histogramme par mois
                        pw.Expanded(
                          child: _buildBarChart(
                            barData,
                            years,
                            months,
                            yearColors,
                            pageWidth - 30, // largeur disponible pour les barres
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

            // Deuxième graphique : Nombre de vols par année
            pw.Text('Nombre de vols par année', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            if (years.isNotEmpty)
              pw.Container(
                height: 120,
                width: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Légende couleurs/années
                    pw.Row(
                      children: [
                        for (var i = 0; i < years.length; i++)
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 12,
                                height: 12,
                                color: yearColors[i % yearColors.length],
                              ),
                              pw.SizedBox(width: 4),
                              pw.Text('${years[i]}', style: pw.TextStyle(fontSize: 10)),
                              pw.SizedBox(width: 12),
                            ],
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    // Histogramme par année
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        // Axe des ordonnées (graduations)
                        pw.Container(
                          width: 28,
                          height: 100,
                          child: pw.Stack(
                            children: [
                              for (var i = 1; i <= 3; i++)
                                pw.Positioned(
                                  left: 0,
                                  bottom: (100.0 * i / 3) - 8,
                                  child: pw.Text(
                                    '${((maxFlightsPerYear / 3) * i).round()}',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              for (var i = 1; i <= 3; i++)
                                pw.Positioned(
                                  left: 20,
                                  right: 0,
                                  bottom: 100.0 * i / 3,
                                  child: pw.Container(height: 1, color: PdfColors.grey400),
                                ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 2),
                        // Barres de l'histogramme (une par année)
                        pw.Expanded(
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < years.length; i++) ...[
                                pw.Expanded(
                                  child: pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    children: [
                                      pw.Container(
                                        width: double.infinity,
                                        height: maxFlightsPerYear == 0
                                            ? 0
                                            : 80 * (flightsByYear[years[i]]!.length / maxFlightsPerYear),
                                        color: yearColors[i % yearColors.length],
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text('${years[i]}', style: pw.TextStyle(fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < years.length - 1)
                                  pw.SizedBox(width: 8), // espace entre les barres
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            pw.SizedBox(height: 16),

            // Date d'export
            pw.Text(
              'Export généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 10),
            ),
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

/// Génère l'histogramme par mois et par année (barres groupées)
pw.Widget _buildBarChart(
  Map<int, List<int>> barData,
  List<int> years,
  List<String> months,
  List<PdfColor> colors,
  double width, {
  int maxY = 3000,
  int barHeight = 100,
}) {
  final maxVal = maxY;
  final barGroupCount = 12;
  final groupWidth = width / barGroupCount;
  final barWidth = (groupWidth * 0.7) / (years.isNotEmpty ? years.length : 1); // barres plus fines
  final barSpacing = (groupWidth * 0.3); // espace entre groupes

  return pw.Stack(
    children: [
      // Barres pour chaque mois et chaque année
      for (var m = 0; m < 12; m++)
        for (var y = 0; y < years.length; y++)
          pw.Positioned(
            left: m * groupWidth + y * barWidth + barSpacing / 2,
            bottom: 16,
            child: pw.Container(
              width: barWidth,
              height: maxVal == 0 ? 0 : barHeight * (barData[years[y]]![m] / maxVal),
              color: colors[y % colors.length],
            ),
          ),
      // Labels des mois
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