import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city_model.dart';
import '../providers/property_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/property_card.dart';
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
    
    final allCityListings = propertyProvider.properties
        .where((p) => p.citySlug == widget.city.slug || p.area.toLowerCase().contains(widget.city.name.toLowerCase()))
        .toList();

    final filteredListings = _activeArea == "all"
        ? allCityListings
        : allCityListings.where((p) => p.area.toLowerCase().contains(_activeArea.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. HERO BANNER SECTION (Matching Web bg-secondary) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                  border: Border(
                    bottom: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back to locations button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Back to locations",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // City Name H1
                    Text(
                      widget.city.name,
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: widget.city.stats.length,
                      itemBuilder: (context, index) {
                        final stat = widget.city.stats[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkLine : AppColors.line,
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
                                  color: isDark ? AppColors.darkMuted : AppColors.muted,
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
                                  color: isDark ? AppColors.terracotta : AppColors.forest,
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

                    // ── 3. POPULAR NEIGHBORHOODS (IF ANY) ──
                    if (widget.city.neighborhoods.isNotEmpty) ...[
                      Text(
                        "Popular Neighborhoods",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 105,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.city.neighborhoods.length,
                          itemBuilder: (context, index) {
                            final n = widget.city.neighborhoods[index];
                            return Container(
                              width: 210,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          n.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.darkInk : AppColors.ink,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.terracotta.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          n.vibe,
                                          style: const TextStyle(
                                            color: AppColors.terracotta,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    n.copy,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── 4. AVAILABLE LISTINGS GRID ──
                    Text(
                      "Available in ${widget.city.name}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkInk : AppColors.forest,
                      ),
                    ),

                    if (widget.city.neighborhoods.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text("All Areas (${allCityListings.length})"),
                              selected: _activeArea == "all",
                              selectedColor: AppColors.terracotta,
                              backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeArea == "all" ? Colors.white : (isDark ? AppColors.darkInk : AppColors.ink),
                              ),
                              onSelected: (_) => setState(() => _activeArea = "all"),
                            ),
                            ...widget.city.neighborhoods.map((n) => Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ChoiceChip(
                                label: Text(n.name),
                                selected: _activeArea.toLowerCase() == n.name.toLowerCase(),
                                selectedColor: AppColors.terracotta,
                                backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _activeArea.toLowerCase() == n.name.toLowerCase() ? Colors.white : (isDark ? AppColors.darkInk : AppColors.ink),
                                ),
                                onSelected: (_) => setState(() => _activeArea = _activeArea.toLowerCase() == n.name.toLowerCase() ? "all" : n.name),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    filteredListings.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                            ),
                            child: Center(
                              child: Text(
                                "No active listings in ${widget.city.name} at the moment.",
                                style: TextStyle(color: isDark ? AppColors.darkMuted : AppColors.muted),
                              ),
                            ),
                          )
                        : Column(
                            children: filteredListings.map((prop) {
                              return PropertyCard(
                                property: prop,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailScreen(property: prop),
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
