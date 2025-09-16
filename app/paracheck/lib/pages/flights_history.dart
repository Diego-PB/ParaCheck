import 'package:flutter/material.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/models/flights.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/models/flights.dart';

class FlightsHistoryPage extends StatefulWidget {
  const FlightsHistoryPage({super.key});

  @override
  State<FlightsHistoryPage> createState() => _FlightsHistoryPageState();
}

class _FlightsHistoryPageState extends State<FlightsHistoryPage> {
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
        _error = 'Impossible de charger les vols: $e';
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Supprimer ce vol'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vol supprimé')));
      }
    }
  }

  void showDetails(Flight flight) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder:
          (_) => Padding(
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
                Text('Date : ${formatDate(flight.date)}'),
                Text('Durée : ${formatDuration(flight.duration)}'),
                Text('Altitude max : ${flight.altitude} m'),
                const SizedBox(height: AppSpacing.md),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ecran de chargement / erreur
    if (_loading) {
      return AppScaffold(
        title: 'Historique des vols',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return AppScaffold(
        title: 'Historique des vols',
        body: Center(child: Text(_error!)),
      );
    }

    // Etat vide
    if (_flights.isEmpty) {
      return AppScaffold(
        title: 'Historique des vols',
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
      title: 'Historique',
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
                  '${formatDate(flight.date)} • ${formatDuration(flight.duration)} • ${flight.altitude} m',
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
