import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import '../providers/app_theme_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/property_card.dart';
import '../widgets/city_card.dart';
import 'property_detail_screen.dart';
import 'city_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _heroLocation = "ado-ekiti";
  String _heroPropType = "any";
  final TextEditingController _budgetController = TextEditingController(
    text: "₦ 1,500,000",
  );

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();
    final themeProvider = context.watch<AppThemeProvider>();
    final userProvider = context.watch<UserProvider>();

    final featuredList = propertyProvider.featuredProperties;
    final cities = propertyProvider.cities;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Navigation Bar matching Web Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo + Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.home_work_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "HomeHub",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkInk
                                : AppColors.forest,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    // Actions Row (Dark/Light toggle + User Avatar)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            themeProvider.isDarkMode
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            color: isDark
                                ? AppColors.darkInk
                                : AppColors.forest,
                            size: 20,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => widget.onNavigateTab(4), // Go to Profile
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              userProvider.avatarUrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // HERO SECTION (Matching exact web layout)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Hero Title
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                          letterSpacing: -0.5,
                        ),
                        children: const [
                          TextSpan(text: "Houses worth\n"),
                          TextSpan(
                            text: "moving in",
                            style: TextStyle(
                              color: AppColors.terracotta,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.terracotta,
                              decorationThickness: 2,
                            ),
                          ),
                          TextSpan(text: " for."),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Hero Subtitle Paragraph
                    Text(
                      "Verified flats, duplexes and student housing across the country, straight from the landlord or a vetted agent. No ghost listings. No payments before you've seen the door.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hero Trust Strip Icons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTrustItem(
                            Icons.verified_user_rounded,
                            "184 Verified Agents",
                            isDark,
                          ),
                          const SizedBox(width: 14),
                          _buildTrustItem(
                            Icons.star_rounded,
                            "4.8 / 5 Verified Ratings",
                            isDark,
                          ),
                          const SizedBox(width: 14),
                          _buildTrustItem(
                            Icons.location_on_rounded,
                            "184 Active Listings",
                            isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // SEARCH WIDGET CARD (Matching Web Search Box)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkLine : AppColors.line,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : AppColors.forest.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Selector
                      const Text(
                        "LOCATION",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _heroLocation,
                        decoration: _searchFormDecoration(isDark),
                        items: const [
                          DropdownMenuItem(
                            value: "ado-ekiti",
                            child: Text("Ado-Ekiti"),
                          ),
                          DropdownMenuItem(
                            value: "ikere",
                            child: Text("Ikere-Ekiti"),
                          ),
                          DropdownMenuItem(
                            value: "iworoko",
                            child: Text("Iworoko-Ekiti"),
                          ),
                          DropdownMenuItem(
                            value: "ikole",
                            child: Text("Ikole-Ekiti"),
                          ),
                        ],
                        onChanged: (v) => setState(() => _heroLocation = v!),
                      ),

                      const SizedBox(height: 12),

                      // Property Type Selector
                      const Text(
                        "PROPERTY TYPE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _heroPropType,
                        decoration: _searchFormDecoration(isDark),
                        items: const [
                          DropdownMenuItem(
                            value: "any",
                            child: Text("Any type"),
                          ),
                          DropdownMenuItem(
                            value: "flat",
                            child: Text("Flat / Apartment"),
                          ),
                          DropdownMenuItem(
                            value: "duplex",
                            child: Text("Duplex"),
                          ),
                          DropdownMenuItem(
                            value: "bungalow",
                            child: Text("Bungalow"),
                          ),
                          DropdownMenuItem(
                            value: "self_contained",
                            child: Text("Self-contained"),
                          ),
                          DropdownMenuItem(
                            value: "mini_flat",
                            child: Text("Mini Flat"),
                          ),
                          DropdownMenuItem(
                            value: "hostel",
                            child: Text("Hostel"),
                          ),
                        ],
                        onChanged: (v) => setState(() => _heroPropType = v!),
                      ),

                      const SizedBox(height: 12),

                      // Max Budget
                      const Text(
                        "MAX BUDGET / YEAR",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _budgetController,
                        decoration: _searchFormDecoration(isDark),
                      ),

                      const SizedBox(height: 16),

                      // Search Action Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          propertyProvider.setSelectedCitySlug(_heroLocation);
                          widget.onNavigateTab(1); // Open Search Screen
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Search Properties",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Filter Chips Below Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Popular searches:",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                                "Self-contained",
                                "2-bedroom in GRA",
                                "Furnished flats",
                                "₦500k – ₦1M",
                                "Student housing",
                              ]
                              .map(
                                (tag) => ActionChip(
                                  label: Text(tag),
                                  backgroundColor: isDark
                                      ? AppColors.darkSurfaceAlt
                                      : AppColors.creamAlt,
                                  side: BorderSide(
                                    color: isDark
                                        ? AppColors.darkLine
                                        : AppColors.line,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkInk
                                        : AppColors.forest,
                                  ),
                                  onPressed: () {
                                    propertyProvider.setSearchQuery(tag);
                                    widget.onNavigateTab(1);
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // FEATURED LISTINGS SECTION HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "FEATURED LISTINGS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Doors opening this week.",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.darkInk
                                  : AppColors.forest,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onNavigateTab(1),
                          child: const Row(
                            children: [
                              Text(
                                "Browse all",
                                style: TextStyle(
                                  color: AppColors.terracotta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_outward_rounded,
                                size: 16,
                                color: AppColors.terracotta,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Discover active homes and rental properties verified on HomeHub directly from verified hosts.",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Featured Listings Carousel
            SliverToBoxAdapter(
              child: propertyProvider.isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.terracotta,
                        ),
                      ),
                    )
                  : featuredList.isEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkLine : AppColors.line,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "No active featured listings found.",
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 335,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 4),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: featuredList.length,
                        itemBuilder: (context, index) {
                          final item = featuredList[index];
                          return PropertyCard(
                            property: item,
                            isHorizontal: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailScreen(property: item),
                                ),
                              );
                            },
                            onFavoriteToggle: () {
                              propertyProvider.toggleFavorite(item.id);
                            },
                          );
                        },
                      ),
                    ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // EXPLORE MARKETS (CITIES) SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "EXPLORE MARKETS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Across the country.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkInk : AppColors.forest,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // City Horizontal Scroll Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 175,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 6),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return CityCard(
                      city: city,
                      onTap: () {
                        if (city.live) {
                          propertyProvider.setSelectedCitySlug(city.slug);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CityDetailScreen(city: city),
                            ),
                          );
                        } else {
                          _showWaitlistDialog(context, city.name, isDark);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.creamAlt,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.forest),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _searchFormDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
      ),
    );
  }

  void _showWaitlistDialog(BuildContext context, String cityName, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "$cityName Launching Soon!",
          style: TextStyle(
            color: isDark ? AppColors.darkInk : AppColors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "We're currently onboarding verified landlords in $cityName for our Q2 2026 expansion. Join the priority waitlist to get early access!",
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You've been added to the priority waitlist!"),
                  backgroundColor: AppColors.forest,
                ),
              );
            },
            child: const Text(
              "Join Waitlist",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
