import 'package:flutter/material.dart';
import 'package:paracheck/design/spacing.dart';
import 'package:paracheck/services/site_repository.dart';
import 'package:paracheck/widgets/app_scaffold.dart';
import 'package:paracheck/widgets/primary_button.dart';

class ManageSitesPage extends StatefulWidget {
  const ManageSitesPage({super.key});

  @override
  State<ManageSitesPage> createState() => _ManageSitesPageState();
}

class _ManageSitesPageState extends State<ManageSitesPage> {
  final _siteRepo = SharedPrefsSiteRepository();
  final TextEditingController _newSiteCtrl = TextEditingController();
  List<String> _sites = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await _siteRepo.getAll();
    setState(() => _sites = list);
  }

  @override
  void dispose() {
    _newSiteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Gérer les sites de vol',
      showReturnButton: true,
      onReturn: () => Navigator.pushNamed(context, '/settings'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSiteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ajouter un site',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              PrimaryButton(
                label: 'Ajouter',
                icon: Icons.add,
                onPressed: () async {
                  final v = _newSiteCtrl.text.trim();
                  if (v.isEmpty) return;
                  await _siteRepo.add(v);
                  _newSiteCtrl.clear();
                  await _refresh();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_sites.isEmpty)
            const Text('Aucun site enregistré pour le moment.')
          else
            Column(
              children: [
                for (int i = 0; i < _sites.length; i++)
                  Card(
                    child: ListTile(
                      title: Text(_sites[i]),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Renommer',
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final controller = TextEditingController(
                                text: _sites[i],
                              );
                              final newName = await showDialog<String>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Renommer le site'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          labelText: 'Nouveau nom',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(
                                                ctx,
                                                controller.text.trim(),
                                              ),
                                          child: const Text('Enregistrer'),
                                        ),
                                      ],
                                    ),
                              );
                              if (newName != null && newName.isNotEmpty) {
                                await _siteRepo.rename(_sites[i], newName);
                                await _refresh();
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Supprimer',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Supprimer'),
                                      content: Text(
                                        'Supprimer "${_sites[i]}" ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: const Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                              );
                              if (ok == true) {
                                await _siteRepo.remove(_sites[i]);
                                await _refresh();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
