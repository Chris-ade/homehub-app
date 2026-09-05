import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/nigeria_locations.dart';
import '../../models/property_model.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/inputs/custom_input_field.dart';
import '../../widgets/inputs/form_input_field.dart';
import '../property/property_view.dart';
import 'add_edit_property.dart';
import 'photo_tour_screen.dart';

class ListingEditorScreen extends StatefulWidget {
  final Property property;

  const ListingEditorScreen({super.key, required this.property});

  @override
  State<ListingEditorScreen> createState() => _ListingEditorScreenState();
}

class _ListingEditorScreenState extends State<ListingEditorScreen> {
  late Property _property;
  int _selectedTab = 0; // 0: Your space, 1: Arrival guide

  // Arrival guide local state
  String _checkInInstructions =
      "Keys can be collected from the estate security post or the designated caretaker upon presentation of tenant verification.";
  String _houseRules =
      "• Quiet hours after 10:00 PM\n• No smoking inside the building\n• Keep compound gate closed at all times\n• Prior notification for large visitor gatherings";
  String _utilitiesInfo =
      "• Central soundproof generator runs 7:00 PM – 12:00 AM daily\n• 24/7 borehole running water with backup overhead tanks\n• Individual prepaid meter for each unit";
  String _wifiInfo =
      "Network: HomeHub-Resident\nPassword: Provided upon lease confirmation";
  String _emergencyContacts =
      "Caretaker Line: +234 803 123 4567\nEstate Security Gate: +234 802 987 6543";

  @override
  void initState() {
    super.initState();
    _property = widget.property;
  }

  String _formatNaira(double amount) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _updateListingField(
    Map<String, dynamic> updates, {
    String? successMessage,
  }) async {
    final landlord = context.read<LandlordProvider>();

    final updated = await landlord.updateListing(_property.id, updates);
    if (!mounted) return;

    if (updated != null) {
      setState(() => _property = updated);
      AppToast.showSuccess(
        context,
        message: successMessage ?? "Listing updated successfully.",
      );
    } else {
      AppToast.showError(
        context,
        message:
            landlord.apiError ?? "Failed to save changes. Please try again.",
      );
    }
  }

  void _openPreviewAsTenant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: _property),
      ),
    );
  }

  void _openPhotoTour() async {
    final updated = await Navigator.push<Property>(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoTourScreen(
          property: _property,
          onPropertyUpdated: (p) => setState(() => _property = p),
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _property = updated);
    }
  }

  void _openFullWizard() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPropertyScreen(existing: _property),
      ),
    );
    if (result == true && mounted) {
      final landlord = context.read<LandlordProvider>();
      await landlord.refresh();
      if (!mounted) return;
      final current = landlord.myProperties.firstWhere(
        (p) => p.id == _property.id,
        orElse: () => _property,
      );
      setState(() => _property = current);
    }
  }

  void _showSettingsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    LucideIcons.sparkles,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  title: const Text(
                    "Open in Step-by-Step Wizard",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    "Walk through the full 8-step creation wizard",
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openFullWizard();
                  },
                ),
                ListTile(
                  leading: Icon(
                    LucideIcons.eye,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  title: const Text(
                    "Preview as Tenant",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    "See how your listing appears in search results",
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openPreviewAsTenant();
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.share_2),
                  title: const Text(
                    "Share Listing",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    "Copy public link to share with prospects",
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    AppToast.showSuccess(
                      context,
                      message: "Listing link copied to clipboard.",
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    LucideIcons.trash_2,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    "Delete Listing",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _confirmDeleteListing();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteListing() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete listing?"),
        content: Text(
          "\"${_property.title}\" will be permanently removed. This action cannot be undone.",
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

    if (confirmed == true && mounted) {
      final ok = await context.read<LandlordProvider>().deleteListing(
        _property.id,
      );
      if (!mounted) return;
      if (ok) {
        AppToast.showSuccess(context, message: "Listing deleted.");
        Navigator.pop(context, true);
      } else {
        AppToast.showError(context, message: "Failed to delete listing.");
      }
    }
  }

  // Bottom Sheet Modals with Custom Design System Inputs

  void _editTitle() {
    final ctrl = TextEditingController(text: _property.title);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _showEditorSheet(
      title: "Edit Title",
      content: FormInputField(
        controller: ctrl,
        label: "Property Title",
        hintText: "e.g. Modern 2-Bedroom Flat",
        isDark: isDark,
      ),
      onSave: () {
        final val = ctrl.text.trim();
        if (val.isNotEmpty) {
          _updateListingField({'title': val});
        }
      },
    );
  }

  void _editPropertyType() {
    String selectedType = _property.type.toLowerCase();
    if (selectedType.contains('hostel') || selectedType.contains('room')) {
      selectedType = 'hostel';
    } else if (selectedType.contains('flat') ||
        selectedType.contains('apartment')) {
      selectedType = 'apartment';
    } else {
      selectedType = 'house';
    }

    final sqftCtrl = TextEditingController(
      text: _property.sqft > 0 ? _property.sqft.toString() : '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _showEditorSheet(
      title: "Property Type & Size",
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Property Category",
                style: TextStyle(
                  fontSize: AppFontSizes.labelLarge,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.surfaceAlt,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.white : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'apartment',
                    child: Text("Apartment / Flat"),
                  ),
                  DropdownMenuItem(
                    value: 'house',
                    child: Text("House / Duplex / Bungalow"),
                  ),
                  DropdownMenuItem(
                    value: 'hostel',
                    child: Text("Hostel / Student Room"),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedType = v);
                },
              ),
              const SizedBox(height: 16),
              FormInputField(
                controller: sqftCtrl,
                label: "Square Footage (sqft)",
                hintText: "e.g. 900",
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ],
          );
        },
      ),
      onSave: () {
        final sqft = int.tryParse(sqftCtrl.text.trim()) ?? _property.sqft;
        _updateListingField({'type': selectedType, 'sqft': sqft});
      },
    );
  }

  void _editSleepingArrangements() {
    int beds = _property.beds;
    int baths = _property.baths;

    _showEditorSheet(
      title: "Rooms & Spaces",
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepperRow(
                "Bedrooms",
                beds,
                (val) => setSheetState(() => beds = val),
              ),
              const Divider(height: 32),
              _buildStepperRow(
                "Bathrooms",
                baths,
                (val) => setSheetState(() => baths = val),
              ),
            ],
          );
        },
      ),
      onSave: () {
        _updateListingField({'bedrooms': beds, 'bathrooms': baths});
      },
    );
  }

  Widget _buildStepperRow(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton.outlined(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(LucideIcons.minus, size: 18),
            ),
            const SizedBox(width: 16),
            Text(
              "$value",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 16),
            IconButton.outlined(
              onPressed: value < 20 ? () => onChanged(value + 1) : null,
              icon: const Icon(LucideIcons.plus, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  void _editPricing() {
    final rentCtrl = TextEditingController(
      text: _property.price.toStringAsFixed(_property.price % 1 == 0 ? 0 : 2),
    );
    final depositCtrl = TextEditingController(
      text: _property.securityDeposit.toStringAsFixed(0),
    );
    String period = _property.period == 'month' ? 'monthly' : 'annually';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _showEditorSheet(
      title: "Pricing & Deposit",
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormInputField(
                controller: rentCtrl,
                label: "Rent Amount (₦) *",
                hintText: "e.g. 850000",
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              Text(
                "Rent Payment Frequency",
                style: TextStyle(
                  fontSize: AppFontSizes.labelLarge,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: period,
                dropdownColor: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.surfaceAlt,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.white : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text("Per Month")),
                  DropdownMenuItem(
                    value: 'annually',
                    child: Text("Per Year (Annual)"),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setSheetState(() => period = v);
                },
              ),
              const SizedBox(height: 16),
              FormInputField(
                controller: depositCtrl,
                label: "Security / Caution Deposit (₦)",
                hintText: "e.g. 100000",
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ],
          );
        },
      ),
      onSave: () {
        final rent = double.tryParse(rentCtrl.text.trim()) ?? _property.price;
        final deposit =
            double.tryParse(depositCtrl.text.trim()) ??
            _property.securityDeposit;
        _updateListingField({
          'rent_amount': rent,
          'rent_period': period,
          'security_deposit': deposit,
        });
      },
    );
  }

  void _editDescription() {
    final ctrl = TextEditingController(text: _property.description);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _showEditorSheet(
      title: "Description",
      content: CustomInputField(
        controller: ctrl,
        hintText:
            "Describe your property features, ambiance, power and water supply, neighborhood...",
        minLines: 4,
        maxLines: 7,
        isDark: isDark,
      ),
      onSave: () {
        _updateListingField({'description': ctrl.text.trim()});
      },
    );
  }

  void _editAmenities() {
    final List<String> currentAmenities = List.from(_property.amenities);
    final customCtrl = TextEditingController();

    const presets = [
      "Water",
      "24/7 Power",
      "Security",
      "Parking",
      "Generator",
      "Wifi",
      "Borehole",
      "Pop Ceiling",
      "Tiled Floor",
      "Serviced",
      "Gated Compound",
      "Fitted Kitchen",
    ];

    _showEditorSheet(
      title: "Amenities & Features",
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Popular Amenities",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((item) {
                  final isSelected = currentAmenities.contains(item);
                  return FilterChip(
                    checkmarkColor: isDark
                        ? AppColors.darkButtonText
                        : AppColors.buttonText,
                    label: Text(item),
                    selected: isSelected,
                    selectedColor: isDark
                        ? AppColors.darkAccent
                        : AppColors.primary,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.surfaceAlt,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                    ),
                    onSelected: (selected) {
                      setSheetState(() {
                        if (selected) {
                          currentAmenities.add(item);
                        } else {
                          currentAmenities.remove(item);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                "Add Custom Amenity",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: customCtrl,
                      hintText: "e.g. Swimming Pool",
                      isDark: isDark,
                      onSubmitted: (_) {
                        final val = customCtrl.text.trim();
                        if (val.isNotEmpty && !currentAmenities.contains(val)) {
                          setSheetState(() => currentAmenities.add(val));
                          customCtrl.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: "Add",
                    isAmber: true,
                    height: 48,
                    onPressed: () {
                      final val = customCtrl.text.trim();
                      if (val.isNotEmpty && !currentAmenities.contains(val)) {
                        setSheetState(() => currentAmenities.add(val));
                        customCtrl.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
      onSave: () {
        _updateListingField({'amenities': currentAmenities});
      },
    );
  }

  void _editLocation() {
    final streetCtrl = TextEditingController(text: _property.streetName);
    final houseNoCtrl = TextEditingController(text: _property.houseNumber);
    final cityCtrl = TextEditingController(text: _property.city);
    String state = _property.state;
    if (!NigeriaLocations.states.contains(state)) {
      state = "Ekiti";
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _showEditorSheet(
      title: "Location Details",
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormInputField(
                controller: cityCtrl,
                label: "City *",
                hintText: "e.g. Ado-Ekiti",
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Text(
                "State *",
                style: TextStyle(
                  fontSize: AppFontSizes.labelLarge,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: state,
                dropdownColor: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.surfaceAlt,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.white : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: NigeriaLocations.states.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => state = v);
                },
              ),
              const SizedBox(height: 12),
              FormInputField(
                controller: streetCtrl,
                label: "Street Name",
                hintText: "e.g. Adebayo Road",
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              FormInputField(
                controller: houseNoCtrl,
                label: "House / Plot Number",
                hintText: "e.g. 12",
                isDark: isDark,
              ),
            ],
          );
        },
      ),
      onSave: () {
        _updateListingField({
          'city': cityCtrl.text.trim(),
          'state': state,
          'street_name': streetCtrl.text.trim(),
          'house_number': houseNoCtrl.text.trim(),
          'address': [
            houseNoCtrl.text.trim(),
            streetCtrl.text.trim(),
          ].where((s) => s.isNotEmpty).join(", "),
        });
      },
    );
  }

  void _editAvailability() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _property.availableDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      _updateListingField({
        'available_from': DateFormat('yyyy-MM-dd').format(picked),
      });
    }
  }

  void _editArrivalGuideSection(
    String sectionTitle,
    String initialValue,
    ValueChanged<String> onSaved,
  ) {
    final ctrl = TextEditingController(text: initialValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _showEditorSheet(
      title: sectionTitle,
      content: CustomInputField(
        controller: ctrl,
        hintText: "Enter $sectionTitle details...",
        minLines: 4,
        maxLines: 7,
        isDark: isDark,
      ),
      onSave: () {
        onSaved(ctrl.text.trim());
        AppToast.showSuccess(context, message: "$sectionTitle updated.");
      },
    );
  }

  void _showEditorSheet({
    required String title,
    required Widget content,
    required VoidCallback onSave,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cabinet Grotesk',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onSave();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Build UI

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrow_left,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Listing editor",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.sliders_horizontal,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            onPressed: _showSettingsMenu,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              // ── Segmented Tab Switch (Your space / Arrival guide) ───────
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              "Your space",
                              style: TextStyle(
                                fontFamily: 'Cabinet Grotesk',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 0
                                    ? (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary)
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              "Arrival guide",
                              style: TextStyle(
                                fontFamily: 'Cabinet Grotesk',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 1
                                    ? (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary)
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Tab 0: "Your space" Content ──────────────────────────────
              if (_selectedTab == 0) ...[
                // Status / Checklist banner
                _buildStatusBanner(isDark),
                const SizedBox(height: 14),

                // Photo Tour Card
                _buildPhotoTourCard(isDark),
                const SizedBox(height: 14),

                // Title Card
                _buildSectionCard(
                  title: "Title",
                  value: _property.title,
                  isDark: isDark,
                  onTap: _editTitle,
                ),
                const SizedBox(height: 14),

                // Property type Card
                _buildSectionCard(
                  title: "Property type",
                  value: "Entire place · ${_property.type}",
                  isDark: isDark,
                  onTap: _editPropertyType,
                ),
                const SizedBox(height: 14),

                // Sleeping arrangements / rooms Card
                _buildSleepingArrangementsCard(isDark),
                const SizedBox(height: 14),

                // Pricing Card
                _buildSectionCard(
                  title: "Pricing",
                  value:
                      "${_formatNaira(_property.price)} / ${_property.period}",
                  isDark: isDark,
                  onTap: _editPricing,
                ),
                const SizedBox(height: 14),

                // Security & Caution deposit Card
                _buildSectionCard(
                  title: "Security deposit",
                  value:
                      "${_formatNaira(_property.securityDeposit)} refundable caution deposit",
                  isDark: isDark,
                  onTap: _editPricing,
                ),
                const SizedBox(height: 14),

                // Availability Card
                _buildSectionCard(
                  title: "Availability",
                  value:
                      "Available from ${DateFormat('d MMM yyyy').format(_property.availableDate)}",
                  isDark: isDark,
                  onTap: _editAvailability,
                ),
                const SizedBox(height: 14),

                // Description Card
                _buildSectionCard(
                  title: "Description",
                  value: _property.description,
                  isDark: isDark,
                  maxLines: 3,
                  onTap: _editDescription,
                ),
                const SizedBox(height: 14),

                // Amenities Card
                _buildAmenitiesCard(isDark),
                const SizedBox(height: 14),

                // Location Map Card
                _buildLocationCard(isDark),
                const SizedBox(height: 14),

                // About the host Card
                _buildAboutHostCard(isDark, user),
              ] else ...[
                // ── Tab 1: "Arrival guide" Content ─────────────────────────
                _buildArrivalGuideCard(
                  title: "Check-in instructions",
                  icon: LucideIcons.key_round,
                  content: _checkInInstructions,
                  isDark: isDark,
                  onTap: () => _editArrivalGuideSection(
                    "Check-in instructions",
                    _checkInInstructions,
                    (v) => setState(() => _checkInInstructions = v),
                  ),
                ),
                const SizedBox(height: 14),

                _buildArrivalGuideCard(
                  title: "House rules",
                  icon: LucideIcons.shield_alert,
                  content: _houseRules,
                  isDark: isDark,
                  onTap: () => _editArrivalGuideSection(
                    "House rules",
                    _houseRules,
                    (v) => setState(() => _houseRules = v),
                  ),
                ),
                const SizedBox(height: 14),

                _buildArrivalGuideCard(
                  title: "Utilities, Power & Water",
                  icon: LucideIcons.zap,
                  content: _utilitiesInfo,
                  isDark: isDark,
                  onTap: () => _editArrivalGuideSection(
                    "Utilities, Power & Water",
                    _utilitiesInfo,
                    (v) => setState(() => _utilitiesInfo = v),
                  ),
                ),
                const SizedBox(height: 14),

                _buildArrivalGuideCard(
                  title: "WiFi & Connectivity",
                  icon: LucideIcons.wifi,
                  content: _wifiInfo,
                  isDark: isDark,
                  onTap: () => _editArrivalGuideSection(
                    "WiFi & Connectivity",
                    _wifiInfo,
                    (v) => setState(() => _wifiInfo = v),
                  ),
                ),
                const SizedBox(height: 14),

                _buildArrivalGuideCard(
                  title: "Emergency & Local Contacts",
                  icon: LucideIcons.phone_call,
                  content: _emergencyContacts,
                  isDark: isDark,
                  onTap: () => _editArrivalGuideSection(
                    "Emergency & Local Contacts",
                    _emergencyContacts,
                    (v) => setState(() => _emergencyContacts = v),
                  ),
                ),
              ],
            ],
          ),

          // ── Floating "👁️ View" Preview Pill Button ──────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _openPreviewAsTenant,
                icon: const Icon(LucideIcons.eye, size: 18),
                label: const Text(
                  "View",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modular Card Builders ────────────────────────────────────────────────

  Widget _buildStatusBanner(bool isDark) {
    final isVerified = _property.status == 'Verified';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? LucideIcons.badge_check : LucideIcons.circle_dot,
            color: isVerified
                ? (isDark ? AppColors.darkTextPrimary : AppColors.primary)
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? "Live & Verified Listing" : "Active Listing",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Published on HomeHub · Ready for inquiries",
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
    );
  }

  Widget _buildPhotoTourCard(bool isDark) {
    final images = _property.propertyImages;
    final photoCount = images.isNotEmpty
        ? images.length
        : _property.gallery.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openPhotoTour,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Photo tour",
                      style: TextStyle(
                        fontFamily: 'Cabinet Grotesk',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Icon(LucideIcons.chevron_right, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${_property.beds} bedroom · ${_property.baths} bath",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Photo preview row
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _property.image,
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.camera, size: 22),
                                const SizedBox(height: 4),
                                Text(
                                  "$photoCount photos",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Organize photos by room",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepingArrangementsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _editSleepingArrangements,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sleeping arrangements",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.bed,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_property.beds} Bedroom${_property.beds == 1 ? '' : 's'}",
                              style: TextStyle(
                                fontFamily: 'Cabinet Grotesk',
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "${_property.baths} Bathroom${_property.baths == 1 ? '' : 's'} · ${_property.sqft > 0 ? '${_property.sqft} sqft' : 'Spacious'}",
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
                      const Icon(LucideIcons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _editAmenities,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amenities",
                      style: TextStyle(
                        fontFamily: 'Cabinet Grotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Icon(LucideIcons.chevron_right, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                if (_property.amenities.isEmpty)
                  Text(
                    "Add amenities and facilities",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _property.amenities.take(6).map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          a,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _editLocation,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                        fontFamily: 'Cabinet Grotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Icon(LucideIcons.chevron_right, size: 20),
                  ],
                ),
                const SizedBox(height: 12),

                // Map mini preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: IgnorePointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            _property.latitude,
                            _property.longitude,
                          ),
                          initialZoom: 14.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.homehub.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  _property.latitude,
                                  _property.longitude,
                                ),
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.house,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${_property.houseNumber.isNotEmpty ? '${_property.houseNumber}, ' : ''}${_property.streetName.isNotEmpty ? '${_property.streetName}, ' : ''}${_property.city}, ${_property.state}, Nigeria",
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
          ),
        ),
      ),
    );
  }

  Widget _buildAboutHostCard(bool isDark, UserProvider user) {
    final hostName = user.name.isNotEmpty ? user.name : _property.agent.name;
    final avatar = user.avatarUrl.isNotEmpty
        ? user.avatarUrl
        : _property.agent.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About the host",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: CachedNetworkImageProvider(avatar),
                ),
                const SizedBox(height: 10),
                Text(
                  hostName,
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Started hosting in 2026 · ${_property.agent.role}",
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: maxLines ?? 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalGuideCard({
    required String title,
    required IconData icon,
    required String content,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(LucideIcons.chevron_right, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
