import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/city_model.dart';
import '../theme/app_theme.dart';

class CityCard extends StatelessWidget {
  final City city;
  final VoidCallback onTap;

  const CityCard({
    super.key,
    required this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkLine : AppColors.line,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: ColorFiltered(
                        colorFilter: city.live
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: CachedNetworkImage(
                          imageUrl: city.heroImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                          ),
                          errorWidget: (context, url, err) => Container(
                            color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                            child: const Icon(Icons.location_city_rounded, color: AppColors.muted),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tag Pill
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: city.live ? AppColors.forest : Colors.black87,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        city.live ? "${city.listingsCount} Listings" : "Coming 2026",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkInk : AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city.state,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
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
