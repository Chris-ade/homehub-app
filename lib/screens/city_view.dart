import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/city_model.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/property_card.dart';
import '../widgets/no_data_widget.dart';
import 'property/property_view.dart';

class CityDetailScreen extends StatefulWidget {
  final City city;

  const CityDetailScreen({super.key, required this.city});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  String _activeArea = "all";
  bool _isMapView = false;
  bool _isSatelliteMode = false;
  final Set<String> _selectedAmenityFilters = {};
  String _selectedPropertyType = "Any";
  RangeValues _priceRange = const RangeValues(100000, 10000000);
  int _selectedBeds = 0;
  int _selectedBaths = 0;

  final MapController _heroMapController = MapController();
  final MapController _feedMapController = MapController();

  final List<String> _quickAmenityList = const [
    "24/7 Power",
    "Wifi",
    "Air conditioning",
    "Serviced",
    "Pool",
    "Parking",
    "Water heater",
    "Furnished",
    "Security",
  ];

  String _formatCompactPrice(double amount) {
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return '₦${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      return '₦${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(0)}k';
    }
    return '₦${amount.toInt()}';
  }

  void _resetAllFilters() {
    setState(() {
      _activeArea = "all";
      _selectedAmenityFilters.clear();
      _selectedPropertyType = "Any";
      _priceRange = const RangeValues(100000, 10000000);
      _selectedBeds = 0;
      _selectedBaths = 0;
    });
  }

  void _showFiltersModal(BuildContext context, bool isDark, int totalCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    // Modal Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filters",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Type of place
                          Text(
                            "Type of place",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                  "Any",
                                  "Flat",
                                  "Apartment",
                                  "Self-contained",
                                  "Duplex",
                                  "Single Room",
                                  "Hostel",
                                ].map((type) {
                                  final isSelected =
                                      _selectedPropertyType == type;
                                  return ChoiceChip(
                                    label: Text(type),
                                    selected: isSelected,
                                    selectedColor: isSelected
                                        ? (isDark
                                              ? AppColors.darkAccent
                                              : AppColors.primary)
                                        : AppColors.surfaceAlt,
                                    backgroundColor: isDark
                                        ? AppColors.darkSurfaceAlt
                                        : AppColors.surfaceAlt,
                                    labelStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary),
                                    ),
                                    onSelected: (_) {
                                      setModalState(() {
                                        _selectedPropertyType = type;
                                      });
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Bedrooms & Bathrooms Counters
                          Text(
                            "Rooms and beds",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Minimum Bedrooms",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.circle_minus,
                                      size: 20,
                                    ),
                                    onPressed: _selectedBeds > 0
                                        ? () {
                                            setModalState(
                                              () => _selectedBeds--,
                                            );
                                            setState(() {});
                                          }
                                        : null,
                                  ),
                                  Text(
                                    _selectedBeds == 0
                                        ? "Any"
                                        : "$_selectedBeds+",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.circle_plus,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setModalState(() => _selectedBeds++);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Minimum Bathrooms",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.circle_minus,
                                      size: 20,
                                    ),
                                    onPressed: _selectedBaths > 0
                                        ? () {
                                            setModalState(
                                              () => _selectedBaths--,
                                            );
                                            setState(() {});
                                          }
                                        : null,
                                  ),
                                  Text(
                                    _selectedBaths == 0
                                        ? "Any"
                                        : "$_selectedBaths+",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.circle_plus,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setModalState(() => _selectedBaths++);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Price Range Section
                          Text(
                            "Price range",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Annual or total rental cost in ${widget.city.name}",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RangeSlider(
                            values: _priceRange,
                            min: 50000,
                            max: 20000000,
                            divisions: 40,
                            activeColor: isDark
                                ? AppColors.darkAccent
                                : AppColors.primary,
                            inactiveColor: isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.surfaceAlt,
                            labels: RangeLabels(
                              _formatCompactPrice(_priceRange.start),
                              _formatCompactPrice(_priceRange.end),
                            ),
                            onChanged: (values) {
                              setModalState(() {
                                _priceRange = values;
                              });
                              setState(() {});
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Min: ${_formatCompactPrice(_priceRange.start)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Max: ${_formatCompactPrice(_priceRange.end)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),

                          // Amenities Checkboxes Section
                          Text(
                            "Amenities",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._quickAmenityList.map((amenity) {
                            final isChecked = _selectedAmenityFilters.contains(
                              amenity,
                            );
                            return CheckboxListTile(
                              value: isChecked,
                              activeColor: isDark
                                  ? AppColors.darkAccent
                                  : AppColors.primary,
                              title: Text(
                                amenity,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    _selectedAmenityFilters.add(amenity);
                                  } else {
                                    _selectedAmenityFilters.remove(amenity);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    // Bottom Action Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.surface,
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _resetAllFilters();
                              });
                            },
                            child: Text(
                              "Clear all",
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              foregroundColor: isDark
                                  ? AppColors.textPrimary
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Show $totalCount properties",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();

    // Filter listings matching city slug (or containing slug) or city name
    final allCityListings = propertyProvider.properties.where((p) {
      final slugMatch =
          p.citySlug.contains(widget.city.slug) ||
          widget.city.slug.contains(p.citySlug);
      final nameMatch =
          p.area.toLowerCase().contains(widget.city.name.toLowerCase()) ||
          p.city.toLowerCase().contains(widget.city.name.toLowerCase());
      return slugMatch || nameMatch;
    }).toList();

    // Extract street data
    final Map<String, int> dynamicStreets = {};
    for (var prop in allCityListings) {
      final sName = prop.streetName.trim().isNotEmpty
          ? prop.streetName.trim()
          : (prop.area.contains(',')
                ? prop.area.split(',').first.trim()
                : prop.area.trim());
      if (sName.isNotEmpty && sName.length > 2) {
        dynamicStreets[sName] = (dynamicStreets[sName] ?? 0) + 1;
      }
    }

    // Filter by active area / street
    var filteredListings = _activeArea == "all"
        ? allCityListings
        : allCityListings.where((p) {
            final sName = p.streetName.trim().isNotEmpty
                ? p.streetName.trim()
                : (p.area.contains(',')
                      ? p.area.split(',').first.trim()
                      : p.area.trim());
            return sName.toLowerCase() == _activeArea.toLowerCase();
          }).toList();

    // Filter by property type
    if (_selectedPropertyType != "Any") {
      filteredListings = filteredListings
          .where(
            (p) => p.type.toLowerCase().contains(
              _selectedPropertyType.toLowerCase(),
            ),
          )
          .toList();
    }

    // Filter by min beds & baths
    if (_selectedBeds > 0) {
      filteredListings = filteredListings
          .where((p) => p.beds >= _selectedBeds)
          .toList();
    }
    if (_selectedBaths > 0) {
      filteredListings = filteredListings
          .where((p) => p.baths >= _selectedBaths)
          .toList();
    }

    // Filter by price range
    filteredListings = filteredListings.where((p) {
      return p.price >= _priceRange.start && p.price <= _priceRange.end;
    }).toList();

    // Filter by amenity quick chips
    if (_selectedAmenityFilters.isNotEmpty) {
      filteredListings = filteredListings.where((p) {
        final amenitiesStr = p.amenities.join(' ').toLowerCase();
        final descriptionStr = p.description.toLowerCase();
        return _selectedAmenityFilters.every(
          (amenity) =>
              amenitiesStr.contains(amenity.toLowerCase()) ||
              descriptionStr.contains(amenity.toLowerCase()),
        );
      }).toList();
    }

    // Center LatLng for Map View
    final LatLng centerLatLng = filteredListings.isNotEmpty
        ? LatLng(
            filteredListings.first.latitude,
            filteredListings.first.longitude,
          )
        : const LatLng(7.6231, 5.2188);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.surfaceAlt,
                          ),
                          child: Icon(
                            LucideIcons.arrow_left,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // City Search Pill Center Header
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.search,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Listings in ${widget.city.name}, ${widget.city.state}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "${filteredListings.length} active listings available",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Full Filter Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.surfaceAlt,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          LucideIcons.sliders_horizontal,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => _showFiltersModal(
                          context,
                          isDark,
                          filteredListings.length,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Feed Body (List View vs Map View)
                Expanded(
                  child: _isMapView
                      ? _buildMapView(isDark, filteredListings, centerLatLng)
                      : _buildListView(
                          isDark,
                          propertyProvider,
                          allCityListings,
                          filteredListings,
                          dynamicStreets,
                          centerLatLng,
                        ),
                ),
              ],
            ),

            // Floating Map / List Toggle Button
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    foregroundColor: isDark
                        ? AppColors.textPrimary
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: Icon(
                    _isMapView ? LucideIcons.list : LucideIcons.map,
                    size: 18,
                  ),
                  label: Text(
                    _isMapView ? "List" : "Map (${filteredListings.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
    bool isDark,
    PropertyProvider propertyProvider,
    List<Property> allCityListings,
    List<Property> filteredListings,
    Map<String, int> dynamicStreets,
    LatLng centerLatLng,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── MAP HERO BANNER + 3-COLUMN STATS ROW ──
          _buildMapHero(isDark, centerLatLng),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QUICK AMENITY CHIPS BAR
                Text(
                  "Filter by feature",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _quickAmenityList.map((amenity) {
                      final isSelected = _selectedAmenityFilters.contains(
                        amenity,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          checkmarkColor: isDark
                              ? AppColors.darkButtonText
                              : const Color.fromRGBO(237, 237, 237, 1),
                          label: Text(amenity),
                          selected: isSelected,
                          selectedColor: isSelected
                              ? (isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primary)
                              : AppColors.surfaceAlt,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.surfaceAlt,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? isDark
                                      ? AppColors.darkButtonText
                                      : AppColors.buttonText
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                          ),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedAmenityFilters.add(amenity);
                              } else {
                                _selectedAmenityFilters.remove(amenity);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // AVAILABLE LISTINGS SECTION HEADER
                Text(
                  "Listings in ${widget.city.name}",
                  style: TextStyle(
                    fontFamily: "Cabinet Grotesk",
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.primary,
                  ),
                ),

                // Dynamic Real Street Filter Chips from API Payload street_name
                if (dynamicStreets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        ChoiceChip(
                          checkmarkColor: isDark
                              ? AppColors.darkButtonText
                              : AppColors.buttonText,
                          label: Text(
                            "All Streets (${allCityListings.length})",
                          ),
                          selected: _activeArea == "all",
                          selectedColor: _activeArea == "all"
                              ? (isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primary)
                              : AppColors.surfaceAlt,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.surfaceAlt,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _activeArea == "all"
                                ? (isDark
                                      ? AppColors.darkButtonText
                                      : AppColors.buttonText)
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                          ),
                          onSelected: (_) =>
                              setState(() => _activeArea = "all"),
                        ),
                        ...dynamicStreets.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ChoiceChip(
                              checkmarkColor: isDark
                                  ? AppColors.darkButtonText
                                  : AppColors.buttonText,
                              label: Text("${entry.key} (${entry.value})"),
                              selected:
                                  _activeArea.toLowerCase() ==
                                  entry.key.toLowerCase(),
                              selectedColor:
                                  _activeArea.toLowerCase() ==
                                      entry.key.toLowerCase()
                                  ? (isDark
                                        ? AppColors.darkAccent
                                        : AppColors.primary)
                                  : AppColors.surfaceAlt,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceAlt
                                  : AppColors.surfaceAlt,
                              labelStyle: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color:
                                    _activeArea.toLowerCase() ==
                                        entry.key.toLowerCase()
                                    ? (isDark
                                          ? AppColors.darkButtonText
                                          : AppColors.buttonText)
                                    : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary),
                              ),
                              onSelected: (_) => setState(
                                () => _activeArea =
                                    _activeArea.toLowerCase() ==
                                        entry.key.toLowerCase()
                                    ? "all"
                                    : entry.key,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Render property cards or no data widget based on filtered listings
                filteredListings.isEmpty
                    ? NoDataWidget(
                        cityName: widget.city.name,
                        title: "No listings found in ${widget.city.name}",
                        message:
                            "We don't have active listings matching your selected filters in this area right now.",
                      )
                    : Column(
                        children: filteredListings.map((prop) {
                          return PropertyCard(
                            property: prop,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailScreen(property: prop),
                                ),
                              );
                            },
                            onFavoriteToggle: () {
                              propertyProvider.toggleFavorite(prop.id);
                            },
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHero(bool isDark, LatLng centerLatLng) {
    return Column(
      children: [
        // Map Hero Banner Container
        Container(
          width: double.infinity,
          height: 250,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _heroMapController,
                options: MapOptions(
                  initialCenter: centerLatLng,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _isSatelliteMode
                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                        : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                    userAgentPackageName: 'com.homehub.app',
                  ),
                  if (_isSatelliteMode)
                    TileLayer(
                      urlTemplate:
                          'https://basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}@2x.png',
                      userAgentPackageName: 'com.homehub.app',
                    ),
                ],
              ),

              // Top Map Pill Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurface : Colors.white)
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.map,
                        size: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.city.name}, ${widget.city.state} ${_isSatelliteMode ? '(Satellite)' : ''}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // On-Screen Map Navigation Buttons (Layer Toggle, Zoom In, Zoom Out, Re-center)
              Positioned(
                bottom: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMapControlButton(
                      isDark: isDark,
                      icon: LucideIcons.layers,
                      active: _isSatelliteMode,
                      onTap: () {
                        setState(() {
                          _isSatelliteMode = !_isSatelliteMode;
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildMapControlButton(
                      isDark: isDark,
                      icon: LucideIcons.plus,
                      onTap: () {
                        final currentZoom = _heroMapController.camera.zoom;
                        _heroMapController.move(
                          _heroMapController.camera.center,
                          currentZoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildMapControlButton(
                      isDark: isDark,
                      icon: LucideIcons.minus,
                      onTap: () {
                        final currentZoom = _heroMapController.camera.zoom;
                        _heroMapController.move(
                          _heroMapController.camera.center,
                          currentZoom - 1,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildMapControlButton(
                      isDark: isDark,
                      icon: LucideIcons.locate_fixed,
                      onTap: () {
                        _heroMapController.move(centerLatLng, 13.0);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── 3-Column Compact Stats Row (No big paddings) ──
        _buildThreeColumnStats(isDark),
      ],
    );
  }

  Widget _buildThreeColumnStats(bool isDark) {
    final stats = widget.city.stats;
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: List.generate(stats.length, (index) {
          final stat = stats[index];
          final isLast = index == stats.length - 1;

          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        right: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stat.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.white : AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMapView(
    bool isDark,
    List<Property> filteredListings,
    LatLng centerLatLng,
  ) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _feedMapController,
          options: MapOptions(initialCenter: centerLatLng, initialZoom: 13.0),
          children: [
            TileLayer(
              urlTemplate: _isSatelliteMode
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
              userAgentPackageName: 'com.homehub.app',
            ),
            if (_isSatelliteMode)
              TileLayer(
                urlTemplate:
                    'https://basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}@2x.png',
                userAgentPackageName: 'com.homehub.app',
              ),
            MarkerLayer(
              markers: filteredListings.map((prop) {
                return Marker(
                  point: LatLng(prop.latitude, prop.longitude),
                  width: 90,
                  height: 36,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailScreen(property: prop),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _formatCompactPrice(prop.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // On-Screen Map Navigation Buttons (Layer Toggle, Zoom In, Zoom Out, Re-center)
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMapControlButton(
                isDark: isDark,
                icon: LucideIcons.layers,
                active: _isSatelliteMode,
                onTap: () {
                  setState(() {
                    _isSatelliteMode = !_isSatelliteMode;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                isDark: isDark,
                icon: LucideIcons.plus,
                onTap: () {
                  final currentZoom = _feedMapController.camera.zoom;
                  _feedMapController.move(
                    _feedMapController.camera.center,
                    currentZoom + 1,
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                isDark: isDark,
                icon: LucideIcons.minus,
                onTap: () {
                  final currentZoom = _feedMapController.camera.zoom;
                  _feedMapController.move(
                    _feedMapController.camera.center,
                    currentZoom - 1,
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                isDark: isDark,
                icon: LucideIcons.locate_fixed,
                onTap: () {
                  _feedMapController.move(centerLatLng, 13.0);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required bool isDark,
    required IconData icon,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.white).withValues(
                  alpha: 0.95,
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: active
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.primary),
          ),
        ),
      ),
    );
  }
}
