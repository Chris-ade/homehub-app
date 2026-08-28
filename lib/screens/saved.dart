import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/property_card.dart';
import '../widgets/custom_button.dart';
import 'property/property_view.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const FavoritesScreen({super.key, this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();
    final favorites = propertyProvider.favoriteProperties;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Saved Properties",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppFontSizes.titleLarge,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  "${favorites.length}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await propertyProvider.fetchListingsFromApi();
        },
        color: isDark ? AppColors.white : AppColors.primary,
        child: favorites.isEmpty
            ? CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceAlt
                                    : AppColors.surfaceAlt,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  LucideIcons.heart,
                                  size: 38,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No Saved Properties Yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap the heart icon on any listing to save it and view it anytime here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (onExploreTap != null) ...[
                              const SizedBox(height: 24),
                              CustomButton(
                                text: "Explore Properties",
                                isPrimary: true,
                                icon: LucideIcons.compass,
                                onPressed: onExploreTap,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final property = favorites[index];
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
    );
  }
}
