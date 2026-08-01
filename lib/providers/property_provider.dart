import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../models/city_model.dart';
import '../data/mock_data.dart';

class PropertyProvider extends ChangeNotifier {
  final List<Property> _properties = List.from(MockData.sampleListings);
  final List<City> _cities = List.from(MockData.sampleCities);

  String _searchQuery = "";
  String _selectedCitySlug = "all";
  String _selectedType = "All";
  RangeValues _priceRange = const RangeValues(0, 5000000);
  int _minBeds = 0;
  bool _showOnlyFavorites = false;

  // Getters
  List<Property> get properties => _properties;
  List<City> get cities => _cities;
  String get searchQuery => _searchQuery;
  String get selectedCitySlug => _selectedCitySlug;
  String get selectedType => _selectedType;
  RangeValues get priceRange => _priceRange;
  int get minBeds => _minBeds;
  bool get showOnlyFavorites => _showOnlyFavorites;

  List<Property> get featuredProperties =>
      _properties.where((p) => p.isFeatured).toList();

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
    if (index != -1) {
      _properties[index].isFavorite = !_properties[index].isFavorite;
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
