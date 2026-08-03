import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:latlong2/latlong.dart';

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
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return "Immediately";
    DateTime? date;
    if (dateInput is DateTime) {
      date = dateInput;
    } else if (dateInput is String && dateInput.isNotEmpty) {
      date = DateTime.tryParse(dateInput);
    }
    if (date == null) return "Immediately";
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchPropertyDetailFromApi(
        widget.property.id,
      );
    });
  }

  IconData _getAmenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains("wifi") || lower.contains("internet")) {
      return LucideIcons.wifi;
    } else if (lower.contains("parking") || lower.contains("car")) {
      return LucideIcons.car_front;
    } else if (lower.contains("security") && !lower.contains("deposit")) {
      return LucideIcons.shield_check;
    } else if (lower.contains("electricity") || lower.contains("generator")) {
      return LucideIcons.zap;
    } else if (lower.contains("water")) {
      return LucideIcons.droplet;
    } else if (lower.contains("air conditioning") || lower.contains("ac")) {
      return LucideIcons.air_vent;
    } else if (lower.contains("pool") || lower.contains("swimming")) {
      return LucideIcons.waves;
    } else if (lower.contains("fenced") ||
        lower.contains("yard") ||
        lower.contains("gated")) {
      return LucideIcons.fence;
    } else if (lower.contains("solar") || lower.contains("solar power")) {
      return LucideIcons.solar_panel;
    } else if (lower.contains("garden")) {
      return LucideIcons.trees;
    } else if (lower.contains("pet")) {
      return LucideIcons.paw_print;
    } else if (lower.contains("waste") ||
        lower.contains("disposal") ||
        lower.contains("trash")) {
      return LucideIcons.trash;
    } else if (lower.contains("clean")) {
      return LucideIcons.sparkles;
    } else if (lower.contains("gym") || lower.contains("fitness")) {
      return LucideIcons.dumbbell;
    } else if (lower.contains("laundry") || lower.contains("washing")) {
      return LucideIcons.washing_machine;
    } else if (lower.contains("balcony")) {
      return LucideIcons.house;
    } else if (lower.contains("cctv") || lower.contains("camera")) {
      return LucideIcons.cctv;
    } else if (lower.contains("furnished") || lower.contains("sofa")) {
      return LucideIcons.sofa;
    } else if (lower.contains("kitchen") ||
        lower.contains("appliance") ||
        lower.contains("cooker")) {
      return LucideIcons.chef_hat;
    } else {
      return LucideIcons.circle_check;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();
    final matches = propertyProvider.properties.where(
      (p) => p.id == widget.property.id,
    );
    final prop = matches.isNotEmpty ? matches.first : widget.property;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmCream,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Photo Gallery Header
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.warmCream,
                leadingWidth: 56,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          prop.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: prop.isFavorite
                              ? AppColors.terracotta
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          propertyProvider.toggleFavorite(prop.id);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Listing link copied to clipboard!",
                              ),
                              backgroundColor: AppColors.forest,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        itemCount: prop.gallery.length,
                        onPageChanged: (idx) =>
                            setState(() => _activeGalleryIndex = idx),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "${_activeGalleryIndex + 1} / ${prop.gallery.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
                      // Badge & Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BadgeChip.status(prop.status, isDark: isDark),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${prop.rating} (${prop.reviewCount} reviews)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkInk
                                      : AppColors.ink,
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
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Location Row
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.map_pin,
                            size: 16,
                            color: AppColors.terracotta,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${prop.area}, ${prop.city}, ${prop.state} State",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Price Header Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkLine : AppColors.line,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prop.period == "month"
                                      ? "MONTHLY RENT"
                                      : "ANNUAL RENT",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.terracotta,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatCurrency(prop.price),
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? AppColors.darkInk
                                        : AppColors.forest,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  prop.period == "month"
                                      ? "${_formatCurrency(prop.price * 12)} / year equivalent"
                                      : "${_formatCurrency(prop.price / 12)} / month equivalent",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Available from ${_formatDate(prop.availableDate)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Property Spec Pills (Beds, Baths, Sqft, Type)
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecPill(
                              LucideIcons.bed_double,
                              "${prop.beds} Bedrooms",
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSpecPill(
                              LucideIcons.bath,
                              "${prop.baths} Baths",
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSpecPill(
                              LucideIcons.maximize,
                              "${prop.sqft} sqft",
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSpecPill(
                              Icons.home_work_outlined,
                              prop.type,
                              isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description Section
                      Text(
                        "About this home",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prop.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // AMENITIES & FEATURES WITH RESPECTIVE ICONS
                      Text(
                        "Amenities & Features",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                        ),
                      ),

                      prop.amenities.isEmpty
                          ? Text(
                              "No amenities listed for this property.",
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                                fontSize: 13,
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: prop.amenities.length,
                              itemBuilder: (context, index) {
                                final amenity = prop.amenities[index];
                                final iconData = _getAmenityIcon(amenity);
                                return Row(
                                  children: [
                                    Icon(
                                      iconData,
                                      size: 22,
                                      color: isDark
                                          ? AppColors.terracotta
                                          : AppColors.forest,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        amenity,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.darkInk
                                              : AppColors.ink,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                      const SizedBox(height: 28),

                      // LOCATION ON THE MAP SECTION
                      Text(
                        "Location on the map",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.map_rounded,
                            size: 16,
                            color: AppColors.terracotta,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final cityText = (prop.city.isNotEmpty)
                                    ? prop.city
                                    : "Ado Ekiti";
                                final stateText = (prop.state.isNotEmpty)
                                    ? prop.state
                                    : "Ekiti";
                                final formattedState =
                                    stateText.endsWith("State")
                                    ? stateText
                                    : "$stateText State";
                                return Text(
                                  "${prop.area}, $cityText, $formattedState",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Interactive Real FlutterMap Box Container
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.creamAlt,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? AppColors.darkLine : AppColors.line,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    prop.latitude,
                                    prop.longitude,
                                  ),
                                  initialZoom: 15.0,
                                  interactionOptions: const InteractionOptions(
                                    flags:
                                        InteractiveFlag.all &
                                        ~InteractiveFlag.rotate,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.homehub.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          prop.latitude,
                                          prop.longitude,
                                        ),
                                        width: 44,
                                        height: 44,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.terracotta,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.terracotta
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Landlord / Agent Info Card with Direct WhatsApp Chat Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkLine : AppColors.line,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                prop.agent.avatarUrl,
                              ),
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
                                      color: isDark
                                          ? AppColors.darkInk
                                          : AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    prop.agent.role,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Contact / Chat Button
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.forest,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {
                                final chatProvider = context
                                    .read<ChatProvider>();
                                final thread = chatProvider.startOrGetThread(
                                  propertyId: prop.id,
                                  propertyTitle: prop.title,
                                  agentName: prop.agent.name,
                                  agentAvatar: prop.agent.avatarUrl,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatDetailScreen(threadId: thread.id),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 110,
                      ), // Space for sticky bottom action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 3. ACTION BUTTONS MATCHING WEB MODEL (Chat, Inspect, E-Sign & Rent) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // WhatsApp / Chat Action
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: const Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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
                          builder: (context) =>
                              ChatDetailScreen(threadId: thread.id),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  // 2. Book Inspection Action
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

                  const SizedBox(width: 8),

                  // 3. E-Sign Lease & Rent Action
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
                          builder: (context) =>
                              ESignEscrowModal(property: prop),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.terracotta),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
