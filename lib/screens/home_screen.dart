import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import '../providers/app_theme_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/property_card.dart';
import '../widgets/city_card.dart';
import '../widgets/glass_container.dart';
import '../data/mock_data.dart';
import 'property_detail_screen.dart';
import 'city_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

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
            // Top Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo + Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "HomeHub",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkInk : AppColors.forest,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Verified Rentals in Ekiti State",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Actions Row (Dark/Light toggle + User Avatar)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                            color: isDark ? AppColors.darkInk : AppColors.forest,
                            size: 20,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onNavigateTab(4), // Go to Profile
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(userProvider.avatarUrl),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hero Banner & Search Glass Box
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  backgroundColor: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.9)
                      : AppColors.forest.withValues(alpha: 0.95),
                  borderColor: AppColors.terracotta.withValues(alpha: 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: AppColors.terracotta, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "Zero Agency Markups • Escrow Protected",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Find Your Next Home\nWithout Friction.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Floating Quick Search Input
                      GestureDetector(
                        onTap: () => onNavigateTab(1), // Open Search Tab
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.forest, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Search area (e.g. Adebayo, Fajuyi, EKSU)...",
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.terracotta,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Filter Type Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ["All", "Flat", "Apartment", "Studio", "Duplex", "Mini Flat"].map((type) {
                            final isSelected = propertyProvider.selectedType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: isSelected,
                                selectedColor: AppColors.terracotta,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    propertyProvider.setSelectedType(type);
                                    onNavigateTab(1);
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
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Featured Properties Carousel Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Featured Listings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkInk : AppColors.ink,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: const Row(
                        children: [
                          Text("See All", style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.terracotta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 330,
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
                            builder: (context) => PropertyDetailScreen(property: item),
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

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Popular Locations Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Explore Cities & Student Hubs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkInk : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

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
                              builder: (context) => CityDetailScreen(city: city),
                            ),
                          );
                        } else {
                          // Show Waitlist Dialog for Lagos / Abuja
                          _showWaitlistDialog(context, city.name, isDark);
                        }
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Why Choose HomeHub Bento Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Why Rent With HomeHub?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkInk : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBentoGrid(isDark),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // How It Works Steps
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildHowItWorks(isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Testimonials
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildTestimonials(isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // FAQ Accordion Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildFAQs(isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: Icons.verified_user_rounded,
                title: "Escrow Deposit",
                subtitle: "Funds released only after physical inspection & keys.",
                color: AppColors.forest,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                icon: Icons.percent_rounded,
                title: "Zero Markups",
                subtitle: "No hidden agent cuts on top of your rent.",
                color: AppColors.terracotta,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12, height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: Icons.check_circle_outline_rounded,
                title: "ID Verified",
                subtitle: "100% verified landlords and property managers.",
                color: Colors.blueAccent,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                icon: Icons.border_color_rounded,
                title: "Digital E-Sign",
                subtitle: "Sign agreements electronically right in app.",
                color: Colors.purple,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.creamAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How HomeHub Works",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          _buildStepRow("1", "Search verified listings in your area", isDark),
          _buildStepRow("2", "Book an inspection (In-Person or Virtual)", isDark),
          _buildStepRow("3", "E-sign digital tenancy agreement", isDark),
          _buildStepRow("4", "Pay rent securely via HomeHub Escrow", isDark),
          _buildStepRow("5", "Receive keys & move in hassle-free!", isDark),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.terracotta,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkInk : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What Our Tenants Say",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.TESTIMONIALS.length,
            itemBuilder: (context, index) {
              final item = MockData.TESTIMONIALS[index];
              return Container(
                width: 260,
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
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(item['image']!),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkInk : AppColors.ink,
                              ),
                            ),
                            Text(
                              item['role']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        "\"${item['quote']!}\"",
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                          height: 1.2,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAQs(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequently Asked Questions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        ...MockData.FAQS.take(3).map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
              ),
              child: ExpansionTile(
                title: Text(
                  faq['q']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkInk : AppColors.ink,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Text(
                      faq['a']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You've been added to the priority waitlist!"),
                  backgroundColor: AppColors.forest,
                ),
              );
            },
            child: const Text("Join Waitlist", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
