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
        child: RefreshIndicator(
          color: AppColors.terracotta,
          onRefresh: () async {
            await Future.wait([
              propertyProvider.fetchListingsFromApi(),
              propertyProvider.fetchLocationStatsFromApi(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            onTap: () =>
                                widget.onNavigateTab(4), // Go to Profile
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
                            color: isDark
                                ? AppColors.darkInk
                                : AppColors.forest,
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
                          fontSize: 16,
                          height: 1.45,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Featured listings",
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
                      Text(
                        "Active homes and rental properties verified on HomeHub directly from verified hosts.",
                        style: TextStyle(
                          fontSize: 14,
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
                        height: 315,
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
                child: propertyProvider.isLoading
                    ? const SizedBox(
                        height: 140,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.terracotta,
                          ),
                        ),
                      )
                    : cities.isEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
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
                            "No active market locations found in database.",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 160,
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
                                  propertyProvider.setSelectedCitySlug(
                                    city.slug,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CityDetailScreen(city: city),
                                    ),
                                  );
                                } else {
                                  _showWaitlistDialog(
                                    context,
                                    city.name,
                                    isDark,
                                  );
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
