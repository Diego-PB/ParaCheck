/*
 * This page displays the user's flight history as a list of recorded flights.
 * It allows viewing details for each flight, including radar chart and debrief, and supports deleting flights.
 * Data is loaded from local storage using the SharedPrefsFlightRepository.
 * The page handles loading, error, and empty states, and supports pull-to-refresh.
 */
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/models/flight.dart';
import 'package:paracheck/models/radar.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

class FlightsHistoryPage extends StatefulWidget {
  const FlightsHistoryPage({super.key});

  @override
  State<FlightsHistoryPage> createState() => _FlightsHistoryPageState();
}

class _FlightsHistoryPageState extends State<FlightsHistoryPage> {
  // Repository for accessing stored flights
  final _flightRepository = SharedPrefsFlightRepository();

  // Loading state for async operations
  bool _loading = true;
  // Error message if loading fails
  String? _error;
  // List of loaded flights
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    // Load flights when the page is initialized
    _reload();
  }

  Future<void> _reload() async {
    // Loads all flights from the repository and updates state
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
    // Confirm and delete a flight at the given index
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
    // Show details for a single flight, including radar chart and debrief
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
                    // Flight site and details
                    Text(
                      flight.site.isEmpty ? 'Site inconnu' : flight.site,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Date : ${flight.formatDate(flight.date)}'),
                    Text('Durée : ${flight.formatDuration(flight.duration)}'),
                    Text('Altitude max : ${flight.altitude} m'),
                    const SizedBox(height: AppSpacing.md),
                    // Radar chart if available
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
                    // Debrief section if available
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
                    // Close button
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
    // Main build method: handles loading, error, empty, and list states
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

    // Empty state: no flights recorded
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
    // List state: show all flights with pull-to-refresh
    return AppScaffold(
      title: 'Historique des vols',
      showReturnButton: true,
      onReturn: () {
        Navigator.pushNamed(context, '/homepage');
      },
      body: RefreshIndicator(
        onRefresh: _reload,
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
    );
  }
}