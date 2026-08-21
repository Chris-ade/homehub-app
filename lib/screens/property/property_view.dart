import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:latlong2/latlong.dart';

import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/badge_chip.dart';
import '../../widgets/app_toast.dart';
import '../messages/message_view.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _activeGalleryIndex = 0;
  bool _startingChat = false;
  bool _isSatelliteMode = false;
  final MapController _mapController = MapController();

  Future<void> _messageAgent(Property prop) async {
    final agentId = prop.agent.id;
    if (agentId.isEmpty) {
      AppToast.showInfo(
        context,
        message: "This listing has no contactable agent yet.",
      );
      return;
    }

    setState(() => _startingChat = true);
    final chatProvider = context.read<ChatProvider>();
    final conversationId = await chatProvider.startConversation(
      participantId: agentId,
      propertyId: prop.id,
      propertyTitle: prop.title,
      agentName: prop.agent.name,
      agentAvatar: prop.agent.avatarUrl,
    );

    if (!mounted) return;
    setState(() => _startingChat = false);

    if (conversationId == null) {
      AppToast.showError(
        context,
        message: "Could not start the conversation. Please try again.",
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(threadId: conversationId),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.offWhite,
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
                    : AppColors.offWhite,
                leadingWidth: 56,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Center(
                    child: Container(
                      width: 35,
                      height: 35,
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
                      width: 35,
                      height: 35,
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
                              ? AppColors.amber
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          final wasFavorite = prop.isFavorite;
                          propertyProvider.toggleFavorite(prop.id);
                          AppToast.showSuccess(
                            context,
                            message: !wasFavorite
                                ? "Saved to your bookmarks"
                                : "Removed from bookmarks",
                            actionLabel: !wasFavorite ? "Undo" : null,
                            onAction: !wasFavorite
                                ? () => propertyProvider.toggleFavorite(prop.id)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: Container(
                      width: 35,
                      height: 35,
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
                          AppToast.showSuccess(
                            context,
                            message: "Listing link copied to clipboard!",
                            actionLabel: "Share",
                            onAction: () {},
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
                        bottom: 26,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
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
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: AppFontSizes.displaySmall,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.teal,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Location Row
                      Row(
                        children: [
                          Icon(
                            LucideIcons.map_pin,
                            size: 15,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.amberDeep,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${prop.area}, ${prop.city}, ${prop.state} State",
                              style: TextStyle(
                                fontSize: 16,
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      Text(
                        "About this home",
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: AppFontSizes.headlineLarge,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prop.description,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyLarge,
                          height: 1.5,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // AMENITIES & FEATURES WITH RESPECTIVE ICONS
                      Text(
                        "What this place offers",
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: AppFontSizes.headlineLarge,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.teal,
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
                                    childAspectRatio: 3.7,
                                  ),
                              itemCount: prop.amenities.length,
                              itemBuilder: (context, index) {
                                final amenity = prop.amenities[index];
                                final iconData = _getAmenityIcon(amenity);
                                return Row(
                                  children: [
                                    Icon(
                                      iconData,
                                      size: 20,
                                      color: isDark
                                          ? AppColors.darkAccent
                                          : AppColors.teal,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        amenity,
                                        style: TextStyle(
                                          fontSize: 17,
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
                        "Where this place is",
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: AppFontSizes.headlineLarge,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Builder(
                        builder: (context) {
                          final cityText = (prop.city.isNotEmpty)
                              ? prop.city
                              : "Ado Ekiti";
                          final stateText = (prop.state.isNotEmpty)
                              ? prop.state
                              : "Ekiti";
                          final formattedState = stateText.endsWith("State")
                              ? stateText
                              : "$stateText State";
                          return Text(
                            "${prop.area}, $cityText, $formattedState",
                            style: TextStyle(
                              fontSize: 17,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Interactive Real FlutterMap Box Container
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.mist,
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
                                mapController: _mapController,
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
                                    urlTemplate: _isSatelliteMode
                                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                        : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                                    userAgentPackageName: 'com.homehub.app',
                                  ),
                                  if (_isSatelliteMode)
                                    TileLayer(
                                      urlTemplate:
                                          'https://basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}@2x.png',
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
                                            color: AppColors.amber,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.amber
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

                              // On-Screen Map Control Buttons (Layer Toggle, Zoom In, Zoom Out, Re-Center)
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildMapControlButton(
                                      isDark: isDark,
                                      icon: LucideIcons.layers,
                                      active: _isSatelliteMode,
                                      onTap: () {
                                        setState(() {
                                          _isSatelliteMode = !_isSatelliteMode;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    _buildMapControlButton(
                                      isDark: isDark,
                                      icon: LucideIcons.plus,
                                      onTap: () {
                                        final currentZoom =
                                            _mapController.camera.zoom;
                                        _mapController.move(
                                          _mapController.camera.center,
                                          currentZoom + 1,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    _buildMapControlButton(
                                      isDark: isDark,
                                      icon: LucideIcons.minus,
                                      onTap: () {
                                        final currentZoom =
                                            _mapController.camera.zoom;
                                        _mapController.move(
                                          _mapController.camera.center,
                                          currentZoom - 1,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    _buildMapControlButton(
                                      isDark: isDark,
                                      icon: LucideIcons.locate_fixed,
                                      onTap: () {
                                        _mapController.move(
                                          LatLng(prop.latitude, prop.longitude),
                                          15.0,
                                        );
                                      },
                                    ),
                                  ],
                                ),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prop.agent.name,
                                    style: TextStyle(
                                      fontFamily: 'Cabinet Grotesk',
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkInk
                                          : AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    prop.agent.role,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
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

          // FLOATING BOTTOM ACTION BAR (Price, Deposit & Agent Actions)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Price & Deposit Box
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _formatCurrency(prop.price),
                                style: TextStyle(
                                  fontFamily: 'Cabinet Grotesk',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.darkAccent
                                      : AppColors.teal,
                                ),
                              ),
                              Text(
                                " / ${prop.period}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Deposit: ${_formatCurrency(prop.securityDeposit)} (Refundable)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 2. Message Agent Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: _startingChat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              LucideIcons.mail,
                              color: Colors.white,
                              size: 18,
                            ),
                      label: const Text(
                        "Message Agent",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _startingChat
                          ? null
                          : () => _messageAgent(prop),
                    ),
                  ],
                ),
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
          Icon(
            icon,
            size: 22,
            color: isDark ? AppColors.darkAccent : AppColors.amberDeep,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required bool isDark,
    required IconData icon,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active
              ? AppColors.amber
              : (isDark ? AppColors.darkSurface : Colors.white).withValues(
                  alpha: 0.95,
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? AppColors.amber
                : (isDark ? AppColors.darkLine : AppColors.line),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: active
                ? Colors.white
                : (isDark ? AppColors.darkInk : AppColors.teal),
          ),
        ),
      ),
    );
  }
}
