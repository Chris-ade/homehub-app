import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    final bookings = bookingProvider.bookings;
    final leases = bookingProvider.leases;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Rentals & Inspections",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.terracotta,
          labelColor: AppColors.terracotta,
          unselectedLabelColor: isDark ? AppColors.darkMuted : AppColors.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
          bookings.isEmpty
              ? _buildEmptyState("No inspection bookings yet.", isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
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
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.forest.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        b.inspectionType,
                                        style: const TextStyle(
                                          color: AppColors.forest,
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
                                        color: isDark ? AppColors.darkInk : AppColors.ink,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      b.area,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: isDark ? AppColors.darkLine : AppColors.line),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.terracotta),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${DateFormat('EEE, MMM d').format(b.date)} @ ${b.timeSlot}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkInk : AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Confirmed",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
                          color: AppColors.terracotta.withValues(alpha: 0.5),
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
                                  color: AppColors.terracotta.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified_user_rounded, size: 14, color: AppColors.terracotta),
                                    SizedBox(width: 4),
                                    Text(
                                      "ESCROW PROTECTED",
                                      style: TextStyle(
                                        color: AppColors.terracotta,
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
                                  color: isDark ? AppColors.darkMuted : AppColors.muted,
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
                              color: isDark ? AppColors.darkInk : AppColors.ink,
                            ),
                          ),
                          Text(
                            l.area,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // E-signature Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : AppColors.creamAlt,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description_rounded, color: AppColors.forest, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Digital Signature Verified:",
                                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                                      ),
                                      Text(
                                        l.signatureText ?? "Signed User",
                                        style: GoogleFonts.caveat(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.terracotta,
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
                                  const Text("Rent Deposit:", style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                  Text(
                                    _formatCurrency(l.annualRent),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkInk : AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              CustomButton(
                                text: "View Keys & Contract",
                                isPrimary: true,
                                height: 36,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Downloading official tenancy contract PDF..."),
                                      backgroundColor: AppColors.forest,
                                    ),
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
          Icon(Icons.event_busy_rounded, size: 60, color: isDark ? AppColors.darkMuted : AppColors.muted),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
