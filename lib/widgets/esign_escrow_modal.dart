import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/property_model.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

class ESignEscrowModal extends StatefulWidget {
  final Property property;

  const ESignEscrowModal({super.key, required this.property});

  @override
  State<ESignEscrowModal> createState() => _ESignEscrowModalState();
}

class _ESignEscrowModalState extends State<ESignEscrowModal> {
  late TextEditingController _sigController;
  bool _agreedToTerms = false;
  int _step = 1; // 1: Review & Sign, 2: Escrow Payment Confirmation

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _sigController = TextEditingController(text: user.name);
  }

  @override
  void dispose() {
    _sigController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkLine : AppColors.line,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header Step Indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _step == 1 ? LucideIcons.pencil : LucideIcons.shield_check,
                    color: AppColors.forest,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _step == 1 ? "E-Sign Tenancy Agreement" : "Secure Escrow Payment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      Text(
                        _step == 1 ? "Step 1 of 2: Digital Signature" : "Step 2 of 2: Funds Protection",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: isDark ? AppColors.darkLine : AppColors.line),
            const SizedBox(height: 16),

            if (_step == 1) ...[
              // Agreement summary box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Property:",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                        Text(
                          widget.property.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkInk : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Annual Rent:",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                        Text(
                          _formatCurrency(widget.property.price),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.terracotta : AppColors.forest,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Agent/Brokerage Fee:",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                        const Text(
                          "₦0 (100% Free)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Interactive Signature Preview with Caveat font
              Text(
                "Digital Signature Preview",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkInk : AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.terracotta.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _sigController.text.isEmpty ? "Your Signature Here" : _sigController.text,
                      style: GoogleFonts.caveat(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.terracotta,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Divider(color: AppColors.terracotta.withValues(alpha: 0.3)),
                    const SizedBox(height: 4),
                    Text(
                      "Legally Binding Electronic Signature",
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _sigController,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Type Full Name for Signature",
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.terracotta,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      "I accept the terms of the digital lease agreement and authorize escrow holding.",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              CustomButton(
                text: "Proceed to Escrow Deposit",
                isTerracotta: true,
                width: double.infinity,
                onPressed: _agreedToTerms && _sigController.text.isNotEmpty
                    ? () => setState(() => _step = 2)
                    : null,
              ),
            ] else ...[
              // Step 2: Escrow Payment Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.forest.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shield_check, color: AppColors.forest, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Escrow Purchase Guarantee",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Your payment is held safely in escrow. Landlord receives funds ONLY after you confirm key handover & inspection.",
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
              ),

              const SizedBox(height: 16),

              // Itemized Breakdown
              _buildSummaryRow("Annual Rent", _formatCurrency(widget.property.price), isDark),
              _buildSummaryRow("Refundable Security Deposit", "₦100,000", isDark),
              _buildSummaryRow("HomeHub Service Fee", "₦0 (Free)", isDark, isHighlight: true),
              Divider(color: isDark ? AppColors.darkLine : AppColors.line),
              _buildSummaryRow(
                "Total Escrow Amount",
                _formatCurrency(widget.property.price + 100000),
                isDark,
                isTotal: true,
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: "Authorize Escrow Payment (${_formatCurrency(widget.property.price + 100000)})",
                isTerracotta: true,
                width: double.infinity,
                onPressed: () {
                  context.read<BookingProvider>().createOrUpdateLease(
                        propertyId: widget.property.id,
                        propertyTitle: widget.property.title,
                        area: widget.property.area,
                        annualRent: widget.property.price,
                        signatureText: _sigController.text,
                      );

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.circle_check, color: Colors.green, size: 48),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "Lease E-Signed & Escrow Locked!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkInk : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        "Congratulations! Your digital lease agreement is active and your funds are secured in HomeHub Escrow until move-in.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                      actions: [
                        CustomButton(
                          text: "View My Rentals",
                          isPrimary: true,
                          width: double.infinity,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => setState(() => _step = 1),
                child: Center(
                  child: Text(
                    "Back to Signature",
                    style: TextStyle(
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark,
      {bool isHighlight = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal || isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight
                  ? Colors.green
                  : (isTotal
                      ? (isDark ? AppColors.terracotta : AppColors.forest)
                      : (isDark ? AppColors.darkInk : AppColors.ink)),
            ),
          ),
        ],
      ),
    );
  }
}
