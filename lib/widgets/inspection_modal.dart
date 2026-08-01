import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/property_model.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

class InspectionModal extends StatefulWidget {
  final Property property;

  const InspectionModal({super.key, required this.property});

  @override
  State<InspectionModal> createState() => _InspectionModalState();
}

class _InspectionModalState extends State<InspectionModal> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = "10:00 AM";
  String _inspectionType = "In-Person Viewing";
  final TextEditingController _noteController = TextEditingController();

  final List<String> _timeSlots = [
    "09:00 AM",
    "10:30 AM",
    "01:00 PM",
    "03:30 PM",
    "05:00 PM",
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.terracotta, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Schedule Inspection",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      Text(
                        widget.property.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: isDark ? AppColors.darkLine : AppColors.line),
            const SizedBox(height: 16),

            // Inspection Type Toggle
            Text(
              "Viewing Method",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkInk : AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    "In-Person Viewing",
                    Icons.how_to_reg_rounded,
                    _inspectionType == "In-Person Viewing",
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    "3D Virtual Tour",
                    Icons.videocam_rounded,
                    _inspectionType == "3D Virtual Tour",
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Select Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Preferred Date",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkInk : AppColors.ink,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.terracotta),
                  label: Text(
                    DateFormat('E, MMM d').format(_selectedDate),
                    style: const TextStyle(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Time Slots horizontal scroll
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = _timeSlots[index];
                  final isSelected = slot == _selectedSlot;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = slot),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.terracotta : AppColors.forest)
                            : (isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? AppColors.darkLine : AppColors.line),
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkInk : AppColors.ink),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Note to agent
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Add any special request or note for agent...",
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line),
                ),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Confirm Button
            CustomButton(
              text: "Confirm Inspection Booking",
              isTerracotta: true,
              width: double.infinity,
              onPressed: () {
                final newBooking = InspectionBooking(
                  id: "bk-${DateTime.now().millisecondsSinceEpoch}",
                  propertyId: widget.property.id,
                  propertyTitle: widget.property.title,
                  propertyImage: widget.property.image,
                  area: widget.property.area,
                  agentName: widget.property.agent.name,
                  agentPhone: widget.property.agent.phone,
                  date: _selectedDate,
                  timeSlot: _selectedSlot,
                  inspectionType: _inspectionType,
                  note: _noteController.text,
                );

                context.read<BookingProvider>().addBooking(newBooking);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.forest,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Inspection booked for ${DateFormat('MMM d').format(_selectedDate)} at $_selectedSlot!",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String title, IconData icon, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _inspectionType = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.terracotta.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : (isDark ? AppColors.darkLine : AppColors.line),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.terracotta : (isDark ? AppColors.darkMuted : AppColors.muted),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.terracotta
                      : (isDark ? AppColors.darkInk : AppColors.ink),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
