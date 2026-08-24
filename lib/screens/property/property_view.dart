import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/modals/inspection.dart';
import '../messages/message_view.dart';

// Modular Widgets
import 'widgets/property_photo_app_bar.dart';
import 'widgets/property_rating_summary_row.dart';
import 'widgets/property_highlights_section.dart';
import 'widgets/property_about_section.dart';
import 'widgets/property_reviews_section.dart';
import 'widgets/property_spaces_section.dart';
import 'widgets/property_amenities_section.dart';
import 'widgets/property_map_section.dart';
import 'widgets/property_host_card.dart';
import 'widgets/property_availability_section.dart';
import 'widgets/property_things_to_know_section.dart';
import 'widgets/property_bottom_bar.dart';

// Modular Modals
import 'modals/about_space_modal.dart';
import 'modals/amenities_modal.dart';
import 'modals/all_reviews_modal.dart';
import 'modals/lease_terms_modal.dart';
import 'modals/tenancy_rules_modal.dart';
import 'modals/utilities_modal.dart';

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

  String _selectedReviewFilter = "All";

  final List<Map<String, dynamic>> _mockReviews = [
    {
      "name": "Samantha",
      "tenure": "8 years on HomeHub",
      "avatar":
          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
      "rating": 5,
      "date": "2 weeks ago",
      "stay": "Stayed a few nights",
      "comment":
          "Second time staying here and had a wonderful stay! The room we originally booked wasn't available, but the host went above and beyond by giving us an even better room instead. The amenities were great and it's located centrally so moving around was good. Everything was comfortable.",
    },
    {
      "name": "Mary",
      "tenure": "6 years on HomeHub",
      "avatar":
          "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80",
      "rating": 5,
      "date": "2 weeks ago",
      "stay": "Stayed a few nights",
      "comment":
          "The location is easy to find, staff were friendly and helpful, the host is very responsive and proactive. My husband and I enjoyed our stay.",
    },
    {
      "name": "Tara",
      "location": "Grass Valley, California",
      "tenure": "2 years on HomeHub",
      "avatar":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80",
      "rating": 5,
      "date": "2 weeks ago",
      "stay": "Stayed one night",
      "comment":
          "Clean, stress free check in, and comfortable stay! After coming in fresh from the airport — it made all the difference to have a stress free welcome.",
    },
    {
      "name": "Bernard",
      "tenure": "6 years on HomeHub",
      "avatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80",
      "rating": 5,
      "date": "July 2026",
      "stay": "Stayed a few nights",
      "comment": "Was a good one. Clean, secure, and very modern.",
    },
    {
      "name": "Wole",
      "location": "Lagos, Nigeria",
      "tenure": "4 years on HomeHub",
      "avatar":
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80",
      "rating": 5,
      "date": "May 2026",
      "stay": "Stayed one night",
      "comment": "Clean and homely. Well managed and peaceful compound.",
    },
    {
      "name": "Oluwaseun",
      "tenure": "5 years on HomeHub",
      "avatar":
          "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80",
      "rating": 5,
      "date": "April 2026",
      "stay": "Stayed one night",
      "comment":
          "Amazing stay in the heart of the city. Close to major restaurants and activities. Friendly staff.",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchPropertyDetailFromApi(
        widget.property.id,
      );
    });
  }

  Future<void> _messageAgent(Property prop) async {
    final agentId = prop.agent.id;
    if (agentId.isEmpty) {
      AppToast.showInfo(
        context,
        message: "This listing has no contactable host yet.",
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

  String _periodLabel(String period) =>
      period.toLowerCase().contains('month') ? 'month' : 'year';

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Divider(
        color: isDark ? AppColors.darkBorder : AppColors.border,
        height: 1,
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertyProvider = context.watch<PropertyProvider>();
    final matches = propertyProvider.properties.where(
      (p) => p.id == widget.property.id,
    );
    final prop = matches.isNotEmpty ? matches.first : widget.property;

    final periodLabel = _periodLabel(prop.period);
    final availableStr = DateFormat('MMMM d, yyyy').format(prop.availableDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. PHOTO CAROUSEL APP BAR ──
              PropertyPhotoAppBar(
                property: prop,
                activeIndex: _activeGalleryIndex,
                onPageChanged: (idx) =>
                    setState(() => _activeGalleryIndex = idx),
                onBack: () => Navigator.pop(context),
                onShare: () {
                  AppToast.showSuccess(
                    context,
                    message: "Listing link copied to clipboard!",
                    actionLabel: "Share",
                    onAction: () {},
                  );
                },
                onToggleFavorite: () {
                  final wasFavorite = prop.isFavorite;
                  propertyProvider.toggleFavorite(prop.id);
                  AppToast.showSuccess(
                    context,
                    message: !wasFavorite
                        ? "Saved to your favorites"
                        : "Removed from favorites",
                    actionLabel: !wasFavorite ? "Undo" : null,
                    onAction: !wasFavorite
                        ? () => propertyProvider.toggleFavorite(prop.id)
                        : null,
                  );
                },
                isDark: isDark,
              ),

              // ── 2. PROPERTY DETAILS CONTENT ──
              SliverToBoxAdapter(
                child: Container(
                  color: isDark ? AppColors.darkBackground : AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Title
                      Text(
                        prop.title,
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle Line 1: Type in Location
                      Text(
                        "${prop.type} in ${prop.city}, ${prop.state}, Nigeria",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Subtitle Line 2: Specs
                      Text(
                        "${prop.beds * 2} guests · ${prop.beds} bedroom · ${prop.beds} bed · ${prop.baths} bath",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Rating / Laurel Wreath / Reviews 3-Part Summary Bar
                      if (prop.reviewCount > 0) ...[
                        PropertyRatingSummaryRow(
                          property: prop,
                          isDark: isDark,
                          onShowAllReviews: () => showAllReviewsModal(
                            context,
                            prop,
                            _mockReviews,
                            isDark,
                          ),
                        ),
                        _buildDivider(isDark),
                      ] else
                        _buildDivider(isDark),

                      _buildDivider(isDark),

                      // ── 4. KEY HIGHLIGHTS LIST ──
                      PropertyHighlightsSection(property: prop, isDark: isDark),

                      _buildDivider(isDark),

                      // ── 5. ABOUT THIS SPACE ──
                      PropertyAboutSection(
                        property: prop,
                        isDark: isDark,
                        onShowMore: () =>
                            showAboutSpaceModal(context, prop, isDark),
                      ),

                      _buildDivider(isDark),

                      // ── 6. RATINGS & REVIEWS ──
                      PropertyReviewsSection(
                        property: prop,
                        mockReviews: _mockReviews,
                        selectedFilter: _selectedReviewFilter,
                        onFilterSelected: (val) =>
                            setState(() => _selectedReviewFilter = val),
                        onShowAllReviews: () => showAllReviewsModal(
                          context,
                          prop,
                          _mockReviews,
                          isDark,
                        ),
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // ── 7. SPACES IN THIS HOME (Only shown when tagged room images exist) ──
                      if (prop.taggedRoomImages.isNotEmpty) ...[
                        PropertySpacesSection(property: prop, isDark: isDark),
                        _buildDivider(isDark),
                      ],

                      // ── 8. WHAT THIS PLACE OFFERS ──
                      PropertyAmenitiesSection(
                        property: prop,
                        isDark: isDark,
                        onShowAll: () =>
                            showAllAmenitiesModal(context, prop, isDark),
                      ),

                      _buildDivider(isDark),

                      // ── 9. WHERE YOU'LL BE (LOCATION & MAP) ──
                      PropertyMapSection(
                        property: prop,
                        mapController: _mapController,
                        isSatelliteMode: _isSatelliteMode,
                        onToggleSatellite: () {
                          setState(() {
                            _isSatelliteMode = !_isSatelliteMode;
                          });
                        },
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // ── 10. AVAILABILITY ──
                      PropertyAvailabilitySection(
                        availableStr: availableStr,
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // ── 3. HOST ROW ──
                      PropertyHostCard(
                        property: prop,
                        isStartingChat: _startingChat,
                        onCallAgent: () {
                          AppToast.showInfo(
                            context,
                            message: "Agent phone: ${prop.agent.phone}",
                            actionLabel: "Copy",
                            onAction: () {},
                          );
                        },
                        onMessageAgent: () => _messageAgent(prop),
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // ── 11. THINGS TO KNOW ──
                      PropertyThingsToKnowSection(
                        onLeaseTerms: () =>
                            showLeaseTermsModal(context, isDark),
                        onTenancyRules: () =>
                            showTenancyRulesModal(context, isDark),
                        onUtilities: () => showUtilitiesModal(context, isDark),
                        onReportListing: () {
                          AppToast.showInfo(
                            context,
                            message: "Listing reported for review. Thank you!",
                          );
                        },
                        isDark: isDark,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 12. FIXED BOTTOM ACTION BAR ──
          PropertyBottomBar(
            property: prop,
            formattedPrice: _formatCurrency(prop.price),
            periodLabel: periodLabel,
            formattedDeposit: _formatCurrency(prop.securityDeposit),
            availableStr: availableStr,
            onBookInspection: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => InspectionModal(property: prop),
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
