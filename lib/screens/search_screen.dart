import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/property_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isMapView = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.compactCurrency(
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();
    final listings = propertyProvider.filteredProperties;

    // Honour a focus request coming from another screen (e.g. the home hero
    // search pill), then clear it so it doesn't refire on the next rebuild.
    if (propertyProvider.searchFocusRequested) {
      propertyProvider.consumeSearchFocusRequest();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Bar & Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (val) =>
                              propertyProvider.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: "Search location, property...",
                            hintStyle: TextStyle(
                              fontFamily: 'Satoshi',
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              size: 20,
                              color: AppColors.forest,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(LucideIcons.x, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      propertyProvider.setSearchQuery("");
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.creamAlt,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter Bottom Sheet Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.creamAlt,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          LucideIcons.sliders_horizontal,
                          color: AppColors.terracotta,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showFilterSheet(context, propertyProvider, isDark),
                      ),

                      const SizedBox(width: 4),

                      // View Toggle (List vs Map)
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: _isMapView
                              ? AppColors.terracotta
                              : (isDark
                                    ? AppColors.darkSurfaceAlt
                                    : AppColors.creamAlt),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          _isMapView
                              ? LucideIcons.list
                              : LucideIcons.map,
                          color: _isMapView
                              ? Colors.white
                              : (isDark ? AppColors.darkInk : AppColors.ink),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isMapView = !_isMapView),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Horizontal Quick Type Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            "All",
                            "Flat",
                            "Apartment",
                            "Self-contained",
                            "Hostel",
                            "Single Room",
                            "Duplex",
                            "Mini Flat",
                            "Bungalow",
                          ].map((type) {
                            final isSelected =
                                propertyProvider.selectedType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: isSelected,
                                selectedColor: AppColors.terracotta,
                                backgroundColor: isDark
                                    ? AppColors.darkSurfaceAlt
                                    : AppColors.creamAlt,
                                labelStyle: TextStyle(
                                  fontFamily: 'Satoshi',
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? AppColors.darkInk
                                            : AppColors.ink),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    propertyProvider.setSelectedType(type);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Active Filters Info Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${listings.length} Properties Available",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkInk : AppColors.forest,
                    ),
                  ),
                  if (propertyProvider.selectedCitySlug != "all" ||
                      propertyProvider.selectedType != "All" ||
                      propertyProvider.searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        propertyProvider.resetFilters();
                      },
                      child: const Text(
                        "Reset Filters",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Body: List View OR Interactive Map View
            Expanded(
              child: _isMapView
                  ? _buildMapView(listings, isDark)
                  : listings.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final property = listings[index];
                        return PropertyCard(
                          property: property,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PropertyDetailScreen(property: property),
                              ),
                            );
                          },
                          onFavoriteToggle: () {
                            propertyProvider.toggleFavorite(property.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(List properties, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.creamAlt,
      child: Stack(
        children: [
          // Visual Map Representation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.map_pin,
                  size: 48,
                  color: AppColors.terracotta,
                ),
                const SizedBox(height: 12),
                Text(
                  "Interactive Property Map View",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkInk : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Showing ${properties.length} pin markers across Nigeria",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          // Floating Property Map Cards Slider at bottom
          if (properties.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  return GestureDetector(
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
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkLine : AppColors.line,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              prop.image,
                              width: 90,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  prop.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkInk
                                        : AppColors.ink,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(prop.price),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.terracotta,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prop.area,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
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
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.building_2,
            size: 60,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
          const SizedBox(height: 16),
          Text(
            "No Properties Match Your Filter",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try broadening your price range or clearing keyword search.",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    PropertyProvider provider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filter Options",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // City selector
                  Text(
                    "Select City / Market",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCityFilterChip(
                        "all",
                        "All Cities",
                        provider,
                        setSheetState,
                        isDark,
                      ),
                      ...provider.cities.map(
                        (c) => _buildCityFilterChip(
                          c.slug,
                          c.name,
                          provider,
                          setSheetState,
                          isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Price Range Slider
                  Text(
                    "Annual Price Range: ${_formatCurrency(provider.priceRange.start)} - ${_formatCurrency(provider.priceRange.end)}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                  RangeSlider(
                    values: provider.priceRange,
                    min: 0,
                    max: 5000000,
                    divisions: 50,
                    activeColor: AppColors.terracotta,
                    onChanged: (values) {
                      setSheetState(() {
                        provider.setPriceRange(values);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCityFilterChip(
    String slug,
    String label,
    PropertyProvider provider,
    StateSetter setSheetState,
    bool isDark,
  ) {
    final isSelected = provider.selectedCitySlug == slug;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.terracotta,
      backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.darkInk : AppColors.ink),
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      onSelected: (sel) {
        if (sel) {
          setSheetState(() {
            provider.setSelectedCitySlug(slug);
          });
        }
      },
    );
  }
}
