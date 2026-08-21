import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:homehub_app/widgets/no_data_widget.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import '../providers/app_theme_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/property_card.dart';
import '../widgets/skeletons/property_card_skeleton.dart';
import '../widgets/cards/city_card.dart';
import '../widgets/skeletons/city_card_skeleton.dart';
import '../widgets/section_header.dart';
import '../widgets/app_toast.dart';
import 'property/property_view.dart';
import 'city_view.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _searchTabIndex = 1;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  /// Jumps to the Search tab with its field pre-focused.
  void _openSearch() {
    context.read<PropertyProvider>().requestSearchFocus();
    widget.onNavigateTab(_searchTabIndex);
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
          color: AppColors.amber,
          onRefresh: () async {
            await Future.wait([
              propertyProvider.fetchListingsFromApi(),
              propertyProvider.fetchLocationStatsFromApi(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Greeting bar + actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_greeting()},",
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userProvider.firstName.isNotEmpty
                                  ? "${userProvider.firstName} 👋"
                                  : "Welcome 👋",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cabinet Grotesk',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? AppColors.darkInk
                                    : AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _circleAction(
                        isDark: isDark,
                        icon: themeProvider.isDarkMode
                            ? LucideIcons.sun
                            : LucideIcons.moon,
                        onTap: () => themeProvider.toggleTheme(),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => widget.onNavigateTab(4), // Profile
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.amber.withValues(
                                alpha: 0.6,
                              ),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              userProvider.avatarUrl,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // HERO — headline, subtitle, search pill, trust chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Cabinet Grotesk',
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: isDark
                                ? AppColors.darkInk
                                : AppColors.teal,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            const TextSpan(text: "Houses worth\n"),
                            TextSpan(
                              text: "moving in",
                              style: TextStyle(
                                fontFamily: 'Cabinet Grotesk',
                                color: isDark ? AppColors.darkAccent : AppColors.amberDeep,
                                decoration: TextDecoration.underline,
                                decorationColor: isDark ? AppColors.darkAccent : AppColors.amberDeep,
                                decorationThickness: 2,
                              ),
                            ),
                            const TextSpan(text: " for."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Verified flats, duplexes and student housing across the country straight from the landlord or a vetted agent.",
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Search pill (routes to Search tab, pre-focused)
                      _buildSearchPill(isDark),

                      const SizedBox(height: 14),

                      // Trust chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _trustChip(
                            isDark,
                            LucideIcons.badge_check,
                            "Verified hosts",
                          ),
                          _trustChip(
                            isDark,
                            LucideIcons.shield_check,
                            "No ghost listings",
                          ),
                          _trustChip(
                            isDark,
                            LucideIcons.door_open,
                            "See before you pay",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // FEATURED LISTINGS header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SectionHeader(
                    title: "Featured listings",
                    subtitle:
                        "Active homes verified on HomeHub directly from hosts.",
                    actionLabel: "Browse all",
                    onAction: () => widget.onNavigateTab(1),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Featured carousel
              SliverToBoxAdapter(
                child: propertyProvider.isLoading
                    ? SizedBox(
                        height: 200,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 4),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) =>
                              const PropertyCardSkeleton(isHorizontal: true),
                        ),
                      )
                    : featuredList.isEmpty
                    ? NoDataWidget(
                        title: "No listings",
                        message:
                            "There's no property listing available at the moment",
                      )
                    : SizedBox(
                        height: 245,
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

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Explore markets header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SectionHeader(title: "Explore markets"),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // City carousel
              SliverToBoxAdapter(
                child: propertyProvider.isLoading
                    ? SizedBox(
                        height: 140,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 6),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) =>
                              const CityCardSkeleton(),
                        ),
                      )
                    : cities.isEmpty
                    ? NoDataWidget(
                        title: "No cities available",
                        message: "There is no data available at the moment.",
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

  Widget _buildSearchPill(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openSearch,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkLine : AppColors.line,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.teal.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                LucideIcons.search,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search by city, area or budget",
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 15,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.arrow_right,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleAction({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkLine : AppColors.line,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isDark ? AppColors.darkInk : AppColors.teal,
          ),
        ),
      ),
    );
  }

  Widget _trustChip(bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.teal.withValues(alpha: 0.25)
            : AppColors.amberLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isDark ? AppColors.darkInk : AppColors.amberDeep,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkInk : AppColors.teal,
            ),
          ),
        ],
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
              backgroundColor: AppColors.amber,
              foregroundColor: AppColors.ink,
            ),
            onPressed: () {
              Navigator.pop(context);
              AppToast.showSuccess(
                context,
                message: "You've been added to the priority waitlist!",
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
