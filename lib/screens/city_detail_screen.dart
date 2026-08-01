import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city_model.dart';
import '../providers/property_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/property_card.dart';
import '../widgets/no_data_widget.dart';
import 'property_detail_screen.dart';

class CityDetailScreen extends StatefulWidget {
  final City city;

  const CityDetailScreen({super.key, required this.city});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  String _activeArea = "all";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();

    // Filter listings matching city slug or city name
    final allCityListings = propertyProvider.properties
        .where(
          (p) =>
              p.citySlug == widget.city.slug ||
              p.area.toLowerCase().contains(widget.city.name.toLowerCase()),
        )
        .toList();

    // Dynamically extract real street_name data ONLY from API payload
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

    final filteredListings = _activeArea == "all"
        ? allCityListings
        : allCityListings.where((p) {
            final sName = p.streetName.trim().isNotEmpty
                ? p.streetName.trim()
                : (p.area.contains(',')
                      ? p.area.split(',').first.trim()
                      : p.area.trim());
            return sName.toLowerCase() == _activeArea.toLowerCase();
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO BANNER SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkLine : AppColors.line,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Name H1
                    Text(
                      "${widget.city.name}, ${widget.city.state}",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkInk : AppColors.forest,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      widget.city.tagline,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. INTRO + STATS STRIP ──
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ABOUT THE MARKET",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "What renting in ${widget.city.name} looks like.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkInk : AppColors.forest,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.city.copy,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2x2 Stats Grid Card
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: widget.city.stats.length,
                      itemBuilder: (context, index) {
                        final stat = widget.city.stats[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkLine
                                  : AppColors.line,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                stat.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stat.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.terracotta
                                      : AppColors.forest,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── 3. AVAILABLE LISTINGS SECTION HEADER ──
                    Text(
                      "Available in ${widget.city.name}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkInk : AppColors.forest,
                      ),
                    ),

                    // Dynamic Real Street Filter Chips from API Payload street_name
                    if (dynamicStreets.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(
                                "All Streets (${allCityListings.length})",
                              ),
                              selected: _activeArea == "all",
                              selectedColor: AppColors.terracotta,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceAlt
                                  : AppColors.creamAlt,
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeArea == "all"
                                    ? Colors.white
                                    : (isDark
                                          ? AppColors.darkInk
                                          : AppColors.ink),
                              ),
                              onSelected: (_) =>
                                  setState(() => _activeArea = "all"),
                            ),
                            ...dynamicStreets.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ChoiceChip(
                                  label: Text("${entry.key} (${entry.value})"),
                                  selected:
                                      _activeArea.toLowerCase() ==
                                      entry.key.toLowerCase(),
                                  selectedColor: AppColors.terracotta,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurfaceAlt
                                      : AppColors.creamAlt,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _activeArea.toLowerCase() ==
                                            entry.key.toLowerCase()
                                        ? Colors.white
                                        : (isDark
                                              ? AppColors.darkInk
                                              : AppColors.ink),
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

                    const SizedBox(height: 16),

                    // Render Real API Listings or Web-Style NoDataWidget
                    filteredListings.isEmpty
                        ? NoDataWidget(
                            cityName: widget.city.name,
                            title: "No properties found in ${widget.city.name}",
                            message:
                                "We don't have active properties listed for this specific area right now.",
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
        ),
      ),
    );
  }
}
