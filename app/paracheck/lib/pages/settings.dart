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

    final yearData = flightsByYear.entries.toList();
    final yearColors = [
      PdfColors.blue,
      PdfColors.red,
      PdfColors.orange,
      PdfColors.green,
      PdfColors.purple,
    ];

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final years = yearData.map((e) => e.key).toList()..sort();
    final barData = <int, List<int>>{};
    for (final y in years) {
      final byMonth = List<int>.filled(12, 0);
      for (final f in flightsByYear[y] ?? []) {
        byMonth[f.date.month - 1]++;
      }
      barData[y] = byMonth;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Statistiques de vols',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              // ... (le reste du contenu du PDF, inchangé) ...
            ],
          );
        },
      ),
    );

    // Format du nom du fichier : donnees_JJ-MM-AAAA.pdf
    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    final fileName = 'donnees_$dateStr.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  List<pw.Widget> _buildPieChart(
    List<MapEntry<int, List<Flight>>> data,
    List<PdfColor> colors,
  ) {
    final total = data.fold<int>(0, (sum, e) => sum + e.value.length);
    double start = 0;
    final widgets = <pw.Widget>[];
    for (var i = 0; i < data.length; i++) {
      final percent = data[i].value.length / total;
      widgets.add(
        pw.Positioned(
          left: 0,
          top: 0,
          child: pw.Container(width: 120, height: 120),
        ),
      );
      start += percent * 360;
    }
    widgets.add(
      pw.Positioned(
        left: 130,
        top: 0,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < data.length; i++)
              pw.Row(
                children: [
                  pw.Container(
                    width: 10,
                    height: 10,
                    color: colors[i % colors.length],
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    '${data[i].key} (${data[i].value.length})',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    return widgets;
  }

  pw.Widget _buildBarChart(
    Map<int, List<int>> barData,
    List<int> years,
    List<String> months,
    List<PdfColor> colors,
  ) {
    final maxVal = barData.values
        .expand((e) => e)
        .fold<int>(0, (a, b) => a > b ? a : b);
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        for (var m = 0; m < 12; m++)
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              for (var y = 0; y < years.length; y++)
                pw.Container(
                  width: 8,
                  height:
                      maxVal == 0 ? 0 : 80 * (barData[years[y]]![m] / maxVal),
                  color: colors[y % colors.length],
                  margin: const pw.EdgeInsets.symmetric(vertical: 1),
                ),
              pw.SizedBox(height: 2),
              pw.Text(months[m], style: pw.TextStyle(fontSize: 7)),
            ],
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
