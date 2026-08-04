import 'package:flutter/material.dart';

import '../models/property_model.dart';
import '../models/city_model.dart';
import '../services/api_client.dart';

class PropertyProvider extends ChangeNotifier {
  final ApiClient _api;

  final List<Property> _properties = [];
  final List<City> _cities = [];

  bool _isLoading = false;
  String? _apiError;

  String _searchQuery = "";
  String _selectedCitySlug = "all";
  String _selectedType = "All";
  RangeValues _priceRange = const RangeValues(0, 5000000);
  int _minBeds = 0;
  bool _showOnlyFavorites = false;

  PropertyProvider(this._api) {
    fetchListingsFromApi();
    fetchLocationStatsFromApi();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get apiError => _apiError;
  List<Property> get properties => _properties;
  List<City> get cities => _cities;
  String get searchQuery => _searchQuery;
  String get selectedCitySlug => _selectedCitySlug;
  String get selectedType => _selectedType;
  RangeValues get priceRange => _priceRange;
  int get minBeds => _minBeds;
  bool get showOnlyFavorites => _showOnlyFavorites;

  List<Property> get featuredProperties {
    final featured = _properties.where((p) => p.isFeatured).toList();
    if (featured.isNotEmpty) {
      return featured;
    }
    return _properties.take(6).toList();
  }

  List<Property> get favoriteProperties =>
      _properties.where((p) => p.isFavorite).toList();

  List<Property> get filteredProperties {
    return _properties.where((p) {
      if (_showOnlyFavorites && !p.isFavorite) return false;

      if (_selectedCitySlug != "all" && p.citySlug != _selectedCitySlug) {
        return false;
      }

      if (_selectedType != "All" && p.type.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }

      if (p.price < _priceRange.start || p.price > _priceRange.end) {
        return false;
      }

      if (_minBeds > 0 && p.beds < _minBeds) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchArea = p.area.toLowerCase().contains(query);
        final matchType = p.type.toLowerCase().contains(query);
        final matchDesc = p.description.toLowerCase().contains(query);
        return matchTitle || matchArea || matchType || matchDesc;
      }

      return true;
    }).toList();
  }

  // Fetch real properties from live API
  Future<void> fetchListingsFromApi() async {
    _isLoading = true;
    _apiError = null;
    notifyListeners();

    try {
      final res = await _api.get('/listings');

      if (res.ok) {
        final dynamic data = res.data;
        List<dynamic>? list;

        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else if (data is Map && data['listings'] is List) {
          list = data['listings'];
        }

        if (list != null && list.isNotEmpty) {
          final List<Property> fetchedProps = [];
          for (var item in list) {
            if (item is Map<String, dynamic>) {
              try {
                fetchedProps.add(Property.fromJson(item));
              } catch (_) {}
            }
          }
          if (fetchedProps.isNotEmpty) {
            _properties.clear();
            _properties.addAll(fetchedProps);
          }
        }
      }
    } catch (e) {
      _apiError = "Could not reach live API backend. Showing cached listings.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // For a returning, already-authenticated user, merge in their saved
    // bookmarks so heart icons reflect server state on launch. Self-guards
    // when signed out.
    await fetchBookmarksFromApi();
  }

  // Fetch detailed property (with full amenities & reviews) from GET /listings/:id
  Future<Property?> fetchPropertyDetailFromApi(String propertyId) async {
    try {
      final res = await _api.get('/listings/$propertyId', timeout: const Duration(seconds: 10));

      if (res.ok) {
        final dynamic data = res.data;
        Map<String, dynamic>? itemMap;
        if (data is Map<String, dynamic>) {
          itemMap = data['data'] is Map<String, dynamic> ? data['data'] : data;
        }
        if (itemMap != null) {
          final updatedProp = Property.fromJson(itemMap);
          final index = _properties.indexWhere((p) => p.id == propertyId);
          if (index != -1) {
            _properties[index] = updatedProp;
          } else {
            _properties.add(updatedProp);
          }
          notifyListeners();
          return updatedProp;
        }
      }
    } catch (_) {}
    return null;
  }

  // Fetch real location stats from live API
  Future<void> fetchLocationStatsFromApi() async {
    try {
      final res = await _api.get('/listings/locations/stats');

      if (res.ok) {
        final dynamic data = res.data;
        List<dynamic>? list;

        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        }

        if (list != null && list.isNotEmpty) {
          final List<City> fetchedCities = [];
          for (var item in list) {
            if (item is Map<String, dynamic>) {
              try {
                fetchedCities.add(City.fromApiStat(item));
              } catch (_) {}
            }
          }
          if (fetchedCities.isNotEmpty) {
            _cities.clear();
            _cities.addAll(fetchedCities);
            notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  // Filter modifiers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCitySlug(String slug) {
    _selectedCitySlug = slug;
    notifyListeners();
  }

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setPriceRange(RangeValues values) {
    _priceRange = values;
    notifyListeners();
  }

  void setMinBeds(int beds) {
    _minBeds = beds;
    notifyListeners();
  }

  void toggleFavorite(String propertyId) {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index == -1) return;

    // Optimistic update for a snappy UI.
    final previous = _properties[index].isFavorite;
    _setFavorite(propertyId, !previous);

    // App requires auth to reach these screens; skip persistence if somehow
    // signed out so we never trigger a spurious 401/session clear.
    if (!_isLoggedIn) return;

    _persistBookmark(propertyId, previous);
  }

  // Persist a bookmark toggle to the backend; revert local state on failure.
  Future<void> _persistBookmark(String propertyId, bool previous) async {
    try {
      final res = await _api.post('/listings/bookmark/$propertyId', auth: true);
      if (!res.isSuccess) {
        _setFavorite(propertyId, previous);
        return;
      }
      // Reconcile with server truth when the response reports it.
      final data = res.data;
      if (data is Map &&
          data['data'] is Map &&
          data['data']['bookmarked'] is bool) {
        _setFavorite(propertyId, data['data']['bookmarked'] as bool);
      }
    } catch (_) {
      _setFavorite(propertyId, previous);
    }
  }

  // Load the authenticated user's saved properties and reflect them locally.
  Future<void> fetchBookmarksFromApi() async {
    if (!_isLoggedIn) return;

    try {
      final res = await _api.get('/listings/bookmark/all', auth: true);
      if (!res.ok) return;

      final dynamic data = res.data;
      List<dynamic>? list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'];
      }
      if (list == null) return;

      final bookmarked = <Property>[];
      for (var item in list) {
        if (item is Map<String, dynamic>) {
          try {
            bookmarked.add(Property.fromJson(item));
          } catch (_) {}
        }
      }

      final ids = bookmarked.map((p) => p.id).toSet();

      // Mark saved state on the listings we already have.
      for (final p in _properties) {
        p.isFavorite = ids.contains(p.id);
      }
      // Add saved properties that aren't in the current listing set so the
      // Saved tab shows them even when they're off the current page.
      for (final b in bookmarked) {
        if (_properties.indexWhere((p) => p.id == b.id) == -1) {
          b.isFavorite = true;
          _properties.add(b);
        }
      }

      notifyListeners();
    } catch (_) {}
  }

  bool get _isLoggedIn {
    final token = _api.authProvider?.accessToken;
    return token != null && token.isNotEmpty;
  }

  void _setFavorite(String propertyId, bool value) {
    final i = _properties.indexWhere((p) => p.id == propertyId);
    if (i != -1) {
      _properties[i].isFavorite = value;
      notifyListeners();
    }
  }

  void resetFilters() {
    _searchQuery = "";
    _selectedCitySlug = "all";
    _selectedType = "All";
    _priceRange = const RangeValues(0, 5000000);
    _minBeds = 0;
    _showOnlyFavorites = false;
    notifyListeners();
  }

  void addProperty(Property newProp) {
    _properties.insert(0, newProp);
    notifyListeners();
  }

  City? getCityBySlug(String slug) {
    try {
      return _cities.firstWhere((c) => c.slug == slug);
    } catch (_) {
      return null;
    }
  }
}
