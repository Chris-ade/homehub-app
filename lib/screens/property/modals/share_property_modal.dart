import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_toast.dart';

/// Shows the Airbnb-style "Share this place" bottom sheet dialog.
void showSharePropertyModal(
  BuildContext context,
  Property property,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final shareUrl = "https://homehub.ng/properties/${property.id}";
      final shareText =
          "Check out ${property.title} in ${property.city} on HomeHub: $shareUrl";

      final ratingStr = property.rating > 0
          ? property.rating.toStringAsFixed(2)
          : '4.85';
      final beds = property.beds > 0 ? property.beds : 1;
      final baths = property.baths > 0 ? property.baths : 1;

      // Summary string: e.g. "Rental unit in Lekki · ★4.79 · 1 bedroom · 1 bed · 1 bath"
      final subtitle =
          "${property.type} in ${property.city} · ★$ratingStr · $beds bedroom · $beds bed · $baths bath";

      final cardBg = isDark
          ? AppColors.darkSurfaceAlt
          : const Color(0xFFF7F7F7);
      final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

      Future<void> copyAndNotify(String label, String message) async {
        await Clipboard.setData(ClipboardData(text: shareText));
        if (context.mounted) {
          Navigator.pop(context);
          AppToast.showSuccess(context, message: message);
        }
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : const Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                "Share this place",
                style: TextStyle(
                  fontFamily: 'Cabinet Grotesk',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 16),

              // Property mini preview card
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: property.image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 52,
                        height: 52,
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.surfaceAlt,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 52,
                        height: 52,
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.surfaceAlt,
                        child: const Icon(Icons.home, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Card 1: Copy Link
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => copyAndNotify(
                      "Copy Link",
                      "Listing link copied to clipboard!",
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Copy Link",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Icon(
                            LucideIcons.copy,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Card 2: Grouped share options
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildShareRow(
                          title: "Email",
                          icon: Icon(
                            LucideIcons.mail,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          isDark: isDark,
                          onTap: () => copyAndNotify(
                            "Email",
                            "Listing link copied for Email sharing!",
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: borderColor,
                          indent: 18,
                          endIndent: 18,
                        ),
                        _buildShareRow(
                          title: "Messages",
                          icon: Icon(
                            LucideIcons.message_square,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          isDark: isDark,
                          onTap: () => copyAndNotify(
                            "Messages",
                            "Listing link copied for Messages!",
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: borderColor,
                          indent: 18,
                          endIndent: 18,
                        ),
                        _buildShareRow(
                          title: "WhatsApp",
                          icon: Icon(
                            LucideIcons.message_circle,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          isDark: isDark,
                          onTap: () => copyAndNotify(
                            "WhatsApp",
                            "Listing link copied for WhatsApp sharing!",
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: borderColor,
                          indent: 18,
                          endIndent: 18,
                        ),
                        _buildShareRow(
                          title: "Messenger",
                          icon: Icon(
                            LucideIcons.send_horizontal,
                            size: 19,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          isDark: isDark,
                          onTap: () => copyAndNotify(
                            "Messenger",
                            "Listing link copied for Messenger sharing!",
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: borderColor,
                          indent: 18,
                          endIndent: 18,
                        ),
                        _buildShareRow(
                          title: "Facebook",
                          icon: Icon(
                            Icons.facebook,
                            size: 22,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          isDark: isDark,
                          onTap: () => copyAndNotify(
                            "Facebook",
                            "Listing link copied for Facebook sharing!",
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: borderColor,
                          indent: 18,
                          endIndent: 18,
                        ),
                        _buildShareRow(
                          title: "Twitter",
                          icon: Text(
                            "𝕏",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          isDark: isDark,
                          onTap: () => copyAndNotify(
                            "Twitter",
                            "Listing link copied for X (Twitter) sharing!",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildShareRow({
  required String title,
  required Widget icon,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          icon,
        ],
      ),
    ),
  );
}
