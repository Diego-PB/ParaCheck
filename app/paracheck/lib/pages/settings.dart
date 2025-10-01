import 'package:flutter/material.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/utils/pdf_export_helper.dart';
import 'package:paracheck/models/flights.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paramètres',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exporter mes données :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _flights.isEmpty || _loading
                  ? null
                  : () async {
                      await exportFlightsPdf(_flights);
                    },
              child: const Text('Exporter en PDF'),
            ),
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text('Erreur : $_error', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}