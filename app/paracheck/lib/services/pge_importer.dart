import 'package:paracheck/services/pge_service.dart';
import 'package:paracheck/services/site_repository.dart';

// Importer to fetch and add sites from ParaGliding Earth (PGE)
class PgeImporter {
  final PgeService pgeService;
  final SiteRepository siteRepository;

  PgeImporter({required this.pgeService, required this.siteRepository});

  Future<void> importCountry({
    required String iso2,
    int limit = 200,
    bool tagWithCountry = true,
  }) async {
    final requested = iso2.toUpperCase();
    final fetched = await pgeService.fetchCountrySiteNames(
      iso2: requested,
      limit: limit,
    );

    // Filter to only those matching the requested country code
    final onlyRequested = fetched.where(
      (s) => s.countryCode.toUpperCase() == requested, // normalize casing
    );

    final seen = <String>{};
    String displayName(String raw, String cc) =>
        tagWithCountry ? '$raw ($cc)' : raw;

    final candidates = <String>[];
    for (final takeoff in onlyRequested) {
      final disp = displayName(takeoff.name, takeoff.countryCode.toUpperCase());
      final key = disp.toLowerCase().trim();
      if (seen.add(key)) {
        candidates.add(disp);
      }
    }
    if (candidates.isEmpty) return;

    final existing = await siteRepository.getAllNames();
    final existingSet = existing.map((e) => e.toLowerCase().trim()).toSet();

    // We do not delete any existing sites, just add new ones
    for (final name in candidates) {
      final k = name.toLowerCase().trim(); // single normalization point
      if (!existingSet.contains(k)) {
        await siteRepository.addName(name);
        existingSet.add(k); // avoid duplicates in this run
      }
    }
  }

  // Import multi-country sites from a list of ISO2 codes
  Future<void> importCountries({
    required List<String> iso2List,
    int limitPerCountry = 200,
    bool tagWithCountry = true,
  }) async {
    for (final code in iso2List) {
      await importCountry(
        iso2: code,
        limit: limitPerCountry,
        tagWithCountry: tagWithCountry,
      );
    }
  }
}
