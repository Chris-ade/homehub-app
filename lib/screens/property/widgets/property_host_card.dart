import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

class PropertyHostCard extends StatelessWidget {
  final Property property;
  final bool isStartingChat;
  final VoidCallback onCallAgent;
  final VoidCallback onMessageAgent;
  final bool isDark;

  const PropertyHostCard({
    super.key,
    required this.property,
    required this.isStartingChat,
    required this.onCallAgent,
    required this.onMessageAgent,
    required this.isDark,
  });

  String _getAgentRoleLabel(String role) {
    switch (role) {
      case "direct_landlord":
        return "owner";
      case "verified_agent":
        return "agent";
      case "caretaker":
        return "property manager";
      default:
        return "agent";
    }
  }

  @override
  Widget build(BuildContext context) {
    final agent = property.agent;
    final hasReviews = property.reviewCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Meet the ${_getAgentRoleLabel(agent.role)}",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar + Stats row ──
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: CachedNetworkImageProvider(
                          agent.avatarUrl,
                        ),
                      ),
                      if (agent.isVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkAccent
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (hasReviews) ...[
                          _buildHostStatCol(
                            "${property.reviewCount}",
                            "Reviews",
                          ),
                          _buildHostStatCol(
                            "${property.rating.toStringAsFixed(1)} ★",
                            "Rating",
                          ),
                        ],
                        if (agent.isVerified)
                          Icon(
                            LucideIcons.shield_check,
                            size: 32,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Agent name & role label ──
              Text(
                agent.name,
                style: TextStyle(
                  fontFamily: 'Cabinet Grotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (agent.isVerified) ...[
                    Icon(
                      LucideIcons.badge_check,
                      size: 14,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    agent.isVerified
                        ? "VERIFIED ${_getAgentRoleLabel(agent.role)}"
                        : "UNVERIFIED ${_getAgentRoleLabel(agent.role).toUpperCase()}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Action Buttons: Call + Message side by side ──
              Row(
                children: [
                  // Call Agent button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onCallAgent,
                      icon: Icon(
                        LucideIcons.phone,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      label: Text(
                        "Call",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Message Host button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isStartingChat ? null : onMessageAgent,
                      icon: isStartingChat
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              LucideIcons.message_circle,
                              size: 16,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                      label: Text(
                        "Message",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── HomeHub protection notice ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.shield_check,
                    size: 18,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "To protect your money and data, always communicate and transact through HomeHub.",
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHostStatCol(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
