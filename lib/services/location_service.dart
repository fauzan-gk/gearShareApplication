import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static List<String>? _cachedCountries;
  static final Map<String, List<String>> _cityCache = {};

  static Future<List<String>> fetchCountries() async {
    if (_cachedCountries != null) return _cachedCountries!;
    try {
      final response = await http
          .get(Uri.parse('https://restcountries.com/v3.1/all?fields=name'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cachedCountries = data
            .map((e) => e['name']['common'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList()
          ..sort();
        return _cachedCountries!;
      }
    } catch (_) {}
    _cachedCountries ??= [
      'Afghanistan', 'Albania', 'Algeria', 'Argentina', 'Australia', 'Austria',
      'Bangladesh', 'Belgium', 'Brazil', 'Bulgaria', 'Cambodia', 'Cameroon',
      'Canada', 'Chile', 'China', 'Colombia', 'Croatia', 'Cuba', 'Cyprus',
      'Czech Republic', 'Denmark', 'Egypt', 'Ethiopia', 'Finland', 'France',
      'Germany', 'Ghana', 'Greece', 'Hungary', 'Iceland', 'India', 'Indonesia',
      'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Japan', 'Jordan',
      'Kazakhstan', 'Kenya', 'Kuwait', 'Malaysia', 'Maldives', 'Mexico',
      'Morocco', 'Myanmar', 'Nepal', 'Netherlands', 'New Zealand', 'Nigeria',
      'Norway', 'Oman', 'Pakistan', 'Philippines', 'Poland', 'Portugal',
      'Qatar', 'Romania', 'Russia', 'Saudi Arabia', 'Senegal', 'Serbia',
      'Singapore', 'Slovakia', 'South Africa', 'South Korea', 'Spain',
      'Sri Lanka', 'Sudan', 'Sweden', 'Switzerland', 'Syria', 'Taiwan',
      'Tajikistan', 'Tanzania', 'Thailand', 'Tunisia', 'Turkey', 'Uganda',
      'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States',
      'Uzbekistan', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
    ];
    return _cachedCountries!;
  }

  static Future<List<String>> searchCities(String query, String country) async {
    if (query.trim().length < 2) return [];
    final cacheKey = '$country:$query';
    if (_cityCache.containsKey(cacheKey)) return _cityCache[cacheKey]!;

    try {
      final countryCode = await _getCountryCode(country);
      if (countryCode == null) return [];

      final response = await http
          .get(Uri.parse(
            'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeQueryComponent(query)}'
            '&countrycodes=$countryCode'
            '&format=json'
            '&type=city'
            '&limit=5',
          ))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final cities = data
            .map((e) => e['display_name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .map((n) => n.split(',').first.trim())
            .toSet()
            .toList();
        _cityCache[cacheKey] = cities;
        return cities;
      }
    } catch (_) {}
    return [];
  }

  static String? _countryCodeCache;

  static Future<String?> _getCountryCode(String country) async {
    if (_countryCodeCache != null) return _countryCodeCache;

    try {
      final response = await http
          .get(Uri.parse(
            'https://restcountries.com/v3.1/name/${Uri.encodeQueryComponent(country)}?fields=cca2',
          ))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final code = data[0]['cca2'] as String?;
          _countryCodeCache = code;
          return code;
        }
      }
    } catch (_) {}
    return null;
  }
}
