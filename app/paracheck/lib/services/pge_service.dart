// ParaGliding Earth

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

// Model for a takeoff site from PGE
class PgeTakeoff {
  final String name;
  final String countryCode;
  PgeTakeoff({required this.name, required this.countryCode});
}

// Service to fetch site names from ParaGliding Earth (PGE) API
class PgeService {
  final String baseUrl;
  const PgeService({
    this.baseUrl = 'http://www.paraglidingearth.com',
  }); // PGE base URL

  // Fetch site names for a given country ISO2 code
  Future<List<PgeTakeoff>> fetchCountrySiteNames({
    required String iso2,
    int limit = 200, // max number of sites to fetch
    Duration timeout = const Duration(seconds: 12),
  }) async {
    // API expects `iso` in lowercase
    final uri = Uri.parse(
      '$baseUrl/api/getCountrySites.php',
    ).replace(queryParameters: {'iso': iso2.toLowerCase(), 'limit': '$limit'});

    final response = await http.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw Exception(
        'PGE HTTP ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final doc = xml.XmlDocument.parse(response.body); // Parse XML response
    final names = <PgeTakeoff>[];
    for (final site in doc.findAllElements('takeoff')) {
      final name = (site.getElement('name')?.innerText ?? '').trim();
      // PGE uses <countryCode>, not <country>
      final countryCode =
          (site.getElement('countryCode')?.innerText ?? '').trim();
      // Skip if either field is missing
      if (name.isEmpty || countryCode.isEmpty) continue;
      names.add(PgeTakeoff(name: name, countryCode: countryCode));
    }
    return names;
  }
}
