import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:homehub_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/property_model.dart';
import '../../providers/landlord_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/cards/landlord_property_card.dart';
import '../../widgets/landlord/stat_card.dart';
import '../../widgets/no_data_widget.dart';
import '../../widgets/skeletons/property_card_skeleton.dart';
import '../property/property_view.dart';
import 'add_edit_property.dart';

/// Landlord/agent dashboard: aggregate stats for the account's listings plus a
/// manageable list of those listings with edit/delete + add.
class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LandlordProvider>().refresh();
    });
  }

  String _formatNaira(double amount) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _refresh() => context.read<LandlordProvider>().refresh();

  void _openAddProperty() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPropertyScreen()),
    );
    if (result == true) await _refresh();
  }

  void _openEditProperty(Property p) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPropertyScreen(existing: p),
      ),
    );
    if (result == true) await _refresh();
  }

  void _openDetail(Property p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: p),
      ),
    );
  }

  Future<void> _confirmDelete(Property p) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final landlord = context.read<LandlordProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Delete listing?",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          "\"${p.title}\" will be permanently removed. This can't be undone.",
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await landlord.deleteListing(p.id);
    if (!mounted) return;
    if (ok) {
      AppToast.showSuccess(context, message: "Listing deleted.");
      await _refresh();
    } else {
      AppToast.showError(
        context,
        message: "Failed to delete listing. Please try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final landlord = context.watch<LandlordProvider>();
    final user = context.watch<UserProvider>();
    final stats = landlord.stats;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: isDark ? AppColors.white : AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── Greeting ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back",
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.firstName.isNotEmpty
                            ? "${user.firstName} 👋"
                            : "Welcome 👋",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── KPI Stat cards ─────────────────────────────────
            if (landlord.isLoading && landlord.myProperties.isEmpty)
              _statSkeleton(isDark)
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  StatCard(
                    label: "Total Properties",
                    value: "${stats.totalProperties}",
                    icon: LucideIcons.house,
                    accent: isDark ? AppColors.darkAccent : AppColors.primary,
                    subtitle: "${stats.newListings} new this month",
                  ),
                  StatCard(
                    label: "Total Revenue",
                    value: _formatNaira(stats.monthlyRevenue),
                    icon: LucideIcons.wallet,
                    accent: isDark ? AppColors.darkAccent : AppColors.primary,
                    subtitle: "Combined rent",
                  ),
                  StatCard(
                    label: "New Listings",
                    value: "${stats.newListings}",
                    icon: LucideIcons.circle_plus,
                    accent: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  StatCard(
                    label: "Verified",
                    value:
                        "${stats.verifiedProperties} of ${stats.totalProperties}",
                    icon: LucideIcons.badge_check,
                    accent: isDark ? AppColors.darkAccent : AppColors.primary,
                    subtitle: stats.totalProperties > 0
                        ? "${((stats.verifiedProperties / stats.totalProperties) * 100).round()}% of total"
                        : "0% of total",
                  ),
                ],
              ),

            const SizedBox(height: 28),

            // ── List a property CTA (Airbnb-style black pill) ──────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _openAddProperty,
                icon: Icon(
                  LucideIcons.plus,
                  size: 20,
                  color: isDark ? AppColors.darkBackground : Colors.white,
                ),
                label: Text(
                  "List a property",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkBackground : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Your Properties section header ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Your Properties",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                if (!landlord.isLoading && landlord.myProperties.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceAlt
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      "${landlord.myProperties.length}",
                      style: TextStyle(
                        fontFamily: 'Cabinet Grotesk',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Properties list / loading / empty state ────────────────────
            if (landlord.isLoading && landlord.myProperties.isEmpty)
              Column(
                children: List.generate(
                    2, (_) => const PropertyCardSkeleton(isLandlord: true)),
              )
            else if (landlord.myProperties.isEmpty)
              const NoDataWidget(
                icon: LucideIcons.house,
                title: "No listings yet",
                message:
                    "Tap \"List a property\" above to publish your first listing.",
              )
            else
              ...landlord.myProperties.map(
                (p) => LandlordPropertyCard(
                  property: p,
                  onTap: () => _openDetail(p),
                  onEdit: () => _openEditProperty(p),
                  onDelete: () => _confirmDelete(p),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statSkeleton(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: List.generate(4, (_) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}
