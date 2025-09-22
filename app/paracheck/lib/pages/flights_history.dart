import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/models/flights.dart';
import 'package:paracheck/models/radar.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

class FlightsHistoryPage extends StatefulWidget {
  const FlightsHistoryPage({super.key});

  @override
  State<FlightsHistoryPage> createState() => _FlightsHistoryPageState();
}

class _FlightsHistoryPageState extends State<FlightsHistoryPage> {
  // --- Statistiques pour l'export PDF ---
  int get totalFlights => _flights.length;
  Duration get totalDuration => _flights.fold(Duration.zero, (d, f) => d + f.duration);
  int get maxDurationMinutes => _flights.isEmpty ? 0 : _flights.map((f) => f.duration.inMinutes).reduce((a, b) => a > b ? a : b);
  int get maxAltitude => _flights.isEmpty ? 0 : _flights.map((f) => f.altitude).reduce((a, b) => a > b ? a : b);
  Set<String> get uniqueSites => _flights.map((f) => f.site).where((s) => s.isNotEmpty).toSet();
  int get totalSites => uniqueSites.length;

  // Regroupement par année et mois pour histogramme
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

  // Distance fictive (à remplacer si la distance existe dans Flight)
  int get totalDistanceKm => 0; // TODO: Remplacer par la vraie distance si dispo
  int get maxDistanceKm => 0; // TODO: Remplacer par la vraie distance si dispo
  void _exportPdf() async {
    final pdf = pw.Document();

    // Formatage durée totale
    String formatDuration(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h${m.toString().padLeft(2, '0')}m';
    }

    // --- Données pour graphiques ---
    // Pie chart : répartition des vols par année
    final yearData = flightsByYear.entries.toList();
    final yearColors = [PdfColors.blue, PdfColors.red, PdfColors.orange, PdfColors.green, PdfColors.purple];

    // Bar chart : nombre de vols par mois pour chaque année
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
              pw.Text('Statistiques de vols', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('Vols : $totalFlights'),
                          pw.Text('Sites : $totalSites'),
                          pw.Text('Temps de vol : ${formatDuration(totalDuration)}'),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Max', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('Altitude : $maxAltitude m'),
                          pw.Text('Durée : ${maxDurationMinutes ~/ 60}h${(maxDurationMinutes % 60).toString().padLeft(2, '0')}m'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Text('Répartition des vols par année', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              // Camembert
              if (yearData.isNotEmpty)
                pw.Container(
                  height: 120,
                  width: 120,
                  child: pw.Stack(
                    children: [
                      ..._buildPieChart(yearData, yearColors),
                      pw.Positioned(
                        left: 0,
                        right: 0,
                        top: 45,
                        child: pw.Center(child: pw.Text('${totalFlights} vols', style: pw.TextStyle(fontSize: 12))),
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 18),
              pw.Text('Nombre de vols par mois', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              // Histogramme
              if (barData.isNotEmpty)
                pw.Container(
                  height: 120,
                  child: _buildBarChart(barData, years, months, yearColors),
                ),
              pw.SizedBox(height: 18),
              pw.Text('Sites visités :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Wrap(
                spacing: 6,
                runSpacing: 2,
                children: uniqueSites.map((site) => pw.Text(site, style: pw.TextStyle(fontSize: 10))).toList(),
              ),
              pw.SizedBox(height: 18),
              pw.Text('Export généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Génère les segments du camembert (pie chart)
  List<pw.Widget> _buildPieChart(List<MapEntry<int, List<Flight>>> data, List<PdfColor> colors) {
    final total = data.fold<int>(0, (sum, e) => sum + e.value.length);
    double start = 0;
    final widgets = <pw.Widget>[];
    for (var i = 0; i < data.length; i++) {
      final percent = data[i].value.length / total;
      widgets.add(
        pw.Positioned(
          left: 0,
          top: 0,
          child: pw.CustomPaint(
            size: const PdfPoint(120, 120),
            //Voir pour le painter
            // painter: (pw.Context context, PdfGraphics canvas, PdfPoint size) {
            //   final sweep = percent * 360;
            //   canvas.setColor(colors[i % colors.length]);
            //   canvas.moveTo(60, 60);
            //   canvas.arc(60, 60, 60, 60, start, start + sweep, true);
            //   canvas.lineTo(60, 60);
            //   canvas.fillPath();
            //   start += sweep;
            // },
          ),
        ),
      );
      start += percent * 360;
    }
    // Légende
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
                  pw.Container(width: 10, height: 10, color: colors[i % colors.length]),
                  pw.SizedBox(width: 4),
                  pw.Text('${data[i].key} (${data[i].value.length})', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
          ],
        ),
      ),
    );
    return widgets;
  }

  // Génère un histogramme (bar chart) simple
  pw.Widget _buildBarChart(Map<int, List<int>> barData, List<int> years, List<String> months, List<PdfColor> colors) {
    final maxVal = barData.values.expand((e) => e).fold<int>(0, (a, b) => a > b ? a : b);
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
                  height: maxVal == 0 ? 0 : 80 * (barData[years[y]]![m] / maxVal),
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
  final _flightRepository = SharedPrefsFlightRepository();

  bool _loading = true;
  String? _error;
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _flightRepository.getAll();
      setState(() {
        _flights = all;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement des vols : $e';
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Supprimer le vol'),
            content: const Text('Êtes-vous sûr de vouloir supprimer ce vol ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _flightRepository.removeAt(index);
      setState(() {
        _flights.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vol supprimé'),
            duration: Duration(milliseconds: 750),
          ),
        );
      }
    }
  }

  void showDetails(Flight flight) {
    final featuresShort = radarFeatures
        .map((f) => f.split(' - ').first)
        .toList(growable: false);

    final radarData =
        flight.radar != null
            ? [flight.radar!.toOrderedList(radarFeatures)]
            : const <List<double>>[];

    final Widget radarWidget = RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1,
        child: RadarChart.light(
          ticks: const [5, 10, 15, 20],
          features: featuresShort,
          data: radarData,
        ),
      ),
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder:
          (_) => SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.site.isEmpty ? 'Site inconnu' : flight.site,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Date : ${flight.formatDate(flight.date)}'),
                    Text('Durée : ${flight.formatDuration(flight.duration)}'),
                    Text('Altitude max : ${flight.altitude} m'),
                    const SizedBox(height: AppSpacing.md),
                    if (flight.radar != null) ...[
                      const Divider(),
                      const Text(
                        'Rose des compétences',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      radarWidget,
                    ] else ...[
                      const SizedBox(height: AppSpacing.md),
                      const Text('Aucune rose enregistrée pour ce vol.'),
                    ],
                    if (flight.debrief.isNotEmpty) ...[
                      const Divider(),
                      const Text(
                        'Débrief',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final e in flight.debrief) ...[
                        Text(
                          e.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(e.value),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ecran de chargement / erreur
    if (_loading) {
      return AppScaffold(
        title: 'Historique des vols',
        showReturnButton: true,
        onReturn: () {
          Navigator.pushNamed(context, '/homepage');
        },
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return AppScaffold(
        title: 'Historique des vols',
        showReturnButton: true,
        onReturn: () {
          Navigator.pushNamed(context, '/homepage');
        },
        body: Center(child: Text(_error!)),
      );
    }

    // Etat vide
    if (_flights.isEmpty) {
      return AppScaffold(
        title: 'Historique des vols',
        showReturnButton: true,
        onReturn: () {
          Navigator.pushNamed(context, '/homepage');
        },
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty_rounded, size: 48),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Aucun vol enregistré pour le moment.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Liste avec pull-to-refesh
    return AppScaffold(
      title: 'Historique des vols',
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/homepage');
      },
      body: RefreshIndicator(
        onRefresh: _reload,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: 0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter en PDF'),
                  onPressed: _exportPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _flights.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final flight = _flights[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.paragliding),
                      title: Text(
                        flight.site.isEmpty ? 'Site inconnu' : flight.site,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${flight.formatDate(flight.date)} • ${flight.formatDuration(flight.duration)} • ${flight.altitude} m',
                      ),
                      onTap: () => showDetails(flight),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(index),
                        tooltip: 'Supprimer',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
