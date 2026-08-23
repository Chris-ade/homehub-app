import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/property_model.dart';
import '../../providers/landlord_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/cards/landlord_property_card.dart';
import '../../widgets/custom_button.dart';
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

  Future<void> _refresh() =>
      context.read<LandlordProvider>().refresh();

  void _openAddProperty() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPropertyScreen(),
      ),
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
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
    final stats = landlord.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              "Welcome back",
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage your properties and track performance.",
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Stat cards
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
                    accent: AppColors.primary,
                    subtitle: "${stats.newListings} new this month",
                  ),
                  StatCard(
                    label: "Total Revenue",
                    value: _formatNaira(stats.monthlyRevenue),
                    icon: LucideIcons.wallet,
                    accent: AppColors.accent,
                    subtitle: "Combined rent",
                  ),
                  StatCard(
                    label: "New Listings",
                    value: "${stats.newListings}",
                    icon: LucideIcons.circle_plus,
                    accent: AppColors.info,
                  ),
                  StatCard(
                    label: "Verified",
                    value:
                        "${stats.verifiedProperties} of ${stats.totalProperties}",
                    icon: LucideIcons.badge_check,
                    accent: AppColors.success,
                    subtitle: stats.totalProperties > 0
                        ? "${((stats.verifiedProperties / stats.totalProperties) * 100).round()}% of total"
                        : "0% of total",
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // List a property
            CustomButton(
              text: "List a New Property",
              isAmber: true,
              icon: LucideIcons.plus,
              width: double.infinity,
              onPressed: _openAddProperty,
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Your Properties",
                    style: TextStyle(
                      fontFamily: 'Cabinet Grotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  "${landlord.myProperties.length}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // My properties list / empty state
            if (landlord.isLoading && landlord.myProperties.isEmpty)
              Column(
                children: List.generate(
                  3,
                  (_) => const PropertyCardSkeleton(),
                ),
              )
            else if (landlord.myProperties.isEmpty)
              const NoDataWidget(
                icon: LucideIcons.house,
                title: "No listings yet",
                message:
                    "Tap \"List a New Property\" to publish your first listing.",
              )
            else
              ...landlord.myProperties.map((p) => LandlordPropertyCard(
                    property: p,
                    onTap: () => _openDetail(p),
                    onEdit: () => _openEditProperty(p),
                    onDelete: () => _confirmDelete(p),
                  )),
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
