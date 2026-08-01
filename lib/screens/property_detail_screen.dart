import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/badge_chip.dart';
import '../widgets/custom_button.dart';
import '../widgets/inspection_modal.dart';
import '../widgets/esign_escrow_modal.dart';
import 'chat_detail_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _activeGalleryIndex = 0;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();
    final prop = widget.property;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Photo Gallery Header
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmCream,
                leading: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: Icon(
                        prop.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: prop.isFavorite ? AppColors.terracotta : Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        propertyProvider.toggleFavorite(prop.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Property link copied to clipboard!"),
                            backgroundColor: AppColors.forest,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        itemCount: prop.gallery.length,
                        onPageChanged: (idx) => setState(() => _activeGalleryIndex = idx),
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: prop.gallery[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),

                      // Image counter indicator
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "${_activeGalleryIndex + 1} / ${prop.gallery.length}",
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Property Content Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BadgeChip.status(prop.status, isDark: isDark),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                "${prop.rating} (${prop.reviewCount} reviews)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkInk : AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Title
                      Text(
                        prop.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Location Area
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.terracotta),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              prop.area,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.creamAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Annual Rent", style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                Text(
                                  _formatCurrency(prop.price),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.terracotta : AppColors.forest,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                "0% Agency Markups",
                                style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Specs Grid (Beds, Baths, Sqft, Type)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSpecPill(Icons.king_bed_outlined, "${prop.beds} Beds", isDark),
                          _buildSpecPill(Icons.bathtub_outlined, "${prop.baths} Baths", isDark),
                          _buildSpecPill(Icons.square_foot_outlined, "${prop.sqft} sqft", isDark),
                          _buildSpecPill(Icons.apartment_rounded, prop.type, isDark),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Divider(color: isDark ? AppColors.darkLine : AppColors.line),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        "About this Property",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prop.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Amenities Grid
                      Text(
                        "Features & Amenities",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: prop.amenities.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.terracotta),
                                const SizedBox(width: 6),
                                Text(
                                  a,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkInk : AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Landlord / Agent Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(prop.agent.avatarUrl),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prop.agent.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkInk : AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    prop.agent.role,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Chat with Agent Button
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.forest,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                              onPressed: () {
                                final chatProvider = context.read<ChatProvider>();
                                final thread = chatProvider.startOrGetThread(
                                  propertyId: prop.id,
                                  propertyTitle: prop.title,
                                  agentName: prop.agent.name,
                                  agentAvatar: prop.agent.avatarUrl,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(threadId: thread.id),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Space for sticky bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Action Bar (Book Inspection & E-Sign Lease)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Schedule Inspection
                  Expanded(
                    child: CustomButton(
                      text: "Inspect",
                      isPrimary: false,
                      icon: Icons.calendar_month_rounded,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => InspectionModal(property: prop),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // E-Sign Lease & Escrow
                  Expanded(
                    child: CustomButton(
                      text: "E-Sign & Rent",
                      isTerracotta: true,
                      icon: Icons.border_color_rounded,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ESignEscrowModal(property: prop),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.terracotta),
          const SizedBox(height: 4),
          Text(
            label,
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
}
