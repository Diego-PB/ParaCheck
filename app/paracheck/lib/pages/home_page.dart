import 'package:flutter/material.dart';
import '../widgets/logo_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Ne fait rien pour l'instant
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau vol', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 32.0,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historique des vols',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: const Icon(Icons.paragliding, color: Colors.white),
                    title: const Text(
                      '12 août 2025',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Durée : 1h32 | Altitude : 1450m',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: const Icon(Icons.paragliding, color: Colors.white),
                    title: const Text(
                      '28 juillet 2025',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Durée : 2h01 | Altitude : 1620m',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: const Icon(Icons.paragliding, color: Colors.white),
                    title: const Text(
                      '15 juin 2025',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Durée : 1h15 | Altitude : 1380m',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(height: 70, color: Theme.of(context).colorScheme.primary),
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  shape: const CircleBorder(),
                  elevation: 6,
                  color: Colors.white,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {}, // Ne fait rien pour l'instant
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LogoWidget(size: 44),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
