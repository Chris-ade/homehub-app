import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_toast.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildStatusBadge(InspectionStatus status, bool isDark) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case InspectionStatus.pending:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = isDark ? Colors.amber.shade300 : Colors.amber.shade800;
        label = "Pending";
        break;
      case InspectionStatus.confirmed:
        bg = Colors.green.withValues(alpha: 0.15);
        fg = isDark ? Colors.green.shade300 : Colors.green.shade700;
        label = "Confirmed";
        break;
      case InspectionStatus.completed:
        bg = AppColors.primary.withValues(alpha: 0.15);
        fg = isDark ? AppColors.darkAccent : AppColors.primary;
        label = "Completed";
        break;
      case InspectionStatus.rescheduled:
        bg = Colors.purple.withValues(alpha: 0.15);
        fg = isDark ? Colors.purple.shade300 : Colors.purple.shade700;
        label = "Rescheduled";
        break;
      case InspectionStatus.cancelled:
        bg = Colors.red.withValues(alpha: 0.15);
        fg = isDark ? Colors.red.shade300 : Colors.red.shade700;
        label = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _confirmCancelBooking(
    BuildContext context,
    InspectionBooking booking,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Cancel Inspection?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          "Are you sure you want to cancel your inspection for ${booking.propertyTitle} on ${DateFormat('MMM d').format(booking.date)}?",
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Keep Booking",
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await context.read<BookingProvider>().cancelBooking(booking.id);
      if (!context.mounted) return;
      if (success) {
        AppToast.showInfo(context, message: "Inspection booking cancelled.");
      } else {
        AppToast.showError(
          context,
          message: "Could not cancel booking. Please try again.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    final bookings = bookingProvider.bookings;
    final leases = bookingProvider.leases;
    final isLoading = bookingProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Rentals & Inspections",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.darkAccent : AppColors.primary,
          labelColor: isDark ? AppColors.darkAccent : AppColors.accent,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Scheduled Inspections"),
            Tab(text: "Leases & Escrow"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Scheduled Inspections List
          RefreshIndicator(
            onRefresh: () => context.read<BookingProvider>().fetchBookings(),
            child: isLoading && bookings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : bookings.isEmpty
                    ? _buildEmptyState("No inspection bookings yet.", isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final b = bookings[index];
                          final canCancel =
                              b.status == InspectionStatus.pending ||
                              b.status == InspectionStatus.confirmed;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        b.propertyImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 70,
                                          height: 70,
                                          color: isDark
                                              ? AppColors.darkSurfaceAlt
                                              : AppColors.surfaceAlt,
                                          child: const Icon(
                                            LucideIcons.image,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              b.inspectionType,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            b.propertyTitle,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            b.area,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.calendar,
                                          size: 16,
                                          color: isDark
                                              ? AppColors.darkAccent
                                              : AppColors.accent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${DateFormat('EEE, MMM d').format(b.date)} @ ${b.timeSlot}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildStatusBadge(b.status, isDark),
                                  ],
                                ),
                                if (canCancel) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _confirmCancelBooking(
                                          context,
                                          b,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 6,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                LucideIcons.x,
                                                size: 13,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "Cancel Inspection",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Tab 2: Active Leases & Escrow Protection
          leases.isEmpty
              ? _buildEmptyState("No active lease agreements yet.", isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leases.length,
                  itemBuilder: (context, index) {
                    final l = leases[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.white.withValues(alpha: 0.5) : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.white.withValues(alpha: 0.15)
                                      : AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.shield_check, size: 14, color: isDark ? AppColors.darkAccent : AppColors.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      "ESCROW PROTECTED",
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkAccent : AppColors.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Agreement #${l.id.substring(0, 7)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            l.propertyTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            l.area,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // E-signature Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.file_text, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Digital Signature Verified:",
                                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        l.signatureText ?? "Signed User",
                                        style: GoogleFonts.caveat(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.darkAccent : AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Rent Deposit:", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(
                                    _formatCurrency(l.annualRent),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              CustomButton(
                                text: "View Keys & Contract",
                                isPrimary: true,
                                height: 36,
                                onPressed: () {
                                  AppToast.showInfo(
                                    context,
                                    message: "Downloading official tenancy contract PDF...",
                                    actionLabel: "Open",
                                    onAction: () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendar_x, size: 60, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
