import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/nigeria_locations.dart';
import '../../models/property_model.dart';
import '../../providers/landlord_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/inputs/form_input_field.dart';

/// Represents a local or remote photo draft with an optional room tag.
class ListingImageDraft {
  final XFile? file;
  String? url;
  String? tag; // 'living_room', 'bedroom', 'kitchen', 'bathroom', 'exterior', 'balcony'
  String? caption;

  ListingImageDraft({
    this.file,
    this.url,
    this.tag,
    this.caption,
  });

  bool get isLocal => file != null;
}

const List<Map<String, String>> _kRoomTagOptions = [
  {"tag": "living_room", "label": "Living Room (Parlour)", "icon": "🛋️"},
  {"tag": "bedroom", "label": "Bedroom", "icon": "🛏️"},
  {"tag": "kitchen", "label": "Kitchen", "icon": "🍳"},
  {"tag": "bathroom", "label": "Bathroom / Toilet", "icon": "🚿"},
  {"tag": "balcony", "label": "Balcony / Veranda", "icon": "🌅"},
  {"tag": "exterior", "label": "Compound / Exterior", "icon": "🏡"},
];

const List<String> _kPresetAmenities = [
  "Water",
  "24/7 Power",
  "Security",
  "Parking",
  "Generator",
  "Wifi",
  "Borehole",
  "Pop Ceiling",
  "Tiled Floor",
  "Serviced"
];

class AddEditPropertyScreen extends StatefulWidget {
  final Property? existing;

  const AddEditPropertyScreen({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _houseNoCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _sqftCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _leaseTermCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _amenityCtrl = TextEditingController();

  // Selections
  String _type = 'apartment'; // apartment | house | hostel
  String? _hostelType; // single_room | self_contained
  String _rentPeriod = 'monthly'; // monthly | annually
  String _state = 'Ekiti';
  DateTime _availableFrom = DateTime.now();

  // Amenities & images
  final List<String> _amenities = [];
  final List<ListingImageDraft> _imageDrafts = [];
  bool _uploadingImages = false;

  bool get _isEditing => widget.isEditing;

  // Wizard state
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 7; // Steps 1 to 7. Step 0 is Intro.

  @override
  void initState() {
    super.initState();
    _currentStep = _isEditing ? 1 : 0;
    _pageController = PageController(initialPage: _currentStep);

    final p = widget.existing;
    if (p != null) {
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description;
      _streetCtrl.text = p.streetName;
      _houseNoCtrl.text = p.houseNumber;
      _cityCtrl.text = p.city;
      _state = p.state.isNotEmpty ? p.state : _state;
      _bedroomsCtrl.text = p.beds.toString();
      _bathroomsCtrl.text = p.baths.toString();
      _sqftCtrl.text = p.sqft.toString();
      _rentCtrl.text = p.price.toStringAsFixed(p.price % 1 == 0 ? 0 : 2);
      _depositCtrl.text = p.securityDeposit.toStringAsFixed(0);
      _leaseTermCtrl.text = "";
      _contactPhoneCtrl.text = p.agent.phone.startsWith("+234 803")
          ? ""
          : p.agent.phone;
      _rentPeriod = p.period == "month" ? "monthly" : "annually";
      _availableFrom = p.availableDate;
      _type = _mapTypeToApi(p.type);
      _hostelType = p.type.toLowerCase().contains("room")
          ? "single_room"
          : "self_contained";
      _amenities.addAll(p.amenities);

      if (p.propertyImages.isNotEmpty) {
        for (final img in p.propertyImages) {
          if (img.url.isNotEmpty) {
            _imageDrafts.add(
              ListingImageDraft(
                url: img.url,
                tag: img.tag,
                caption: img.caption,
              ),
            );
          }
        }
      } else {
        for (final u in p.gallery) {
          if (u.isNotEmpty) {
            _imageDrafts.add(ListingImageDraft(url: u));
          }
        }
      }
    } else {
      // Default beds/baths if empty
      _bedroomsCtrl.text = "1";
      _bathroomsCtrl.text = "1";
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _titleCtrl, _descCtrl, _streetCtrl, _houseNoCtrl, _cityCtrl,
      _bedroomsCtrl, _bathroomsCtrl, _sqftCtrl, _rentCtrl, _depositCtrl,
      _leaseTermCtrl, _contactPhoneCtrl, _amenityCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _mapTypeToApi(String type) {
    final t = type.toLowerCase();
    if (t.contains('hostel') || t.contains('room')) return 'hostel';
    if (t.contains('flat') || t.contains('apartment') || t.contains('self')) {
      return 'apartment';
    }
    return 'house';
  }

  String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(limit: 10);
      if (picked.isNotEmpty) {
        setState(() {
          for (final f in picked) {
            _imageDrafts.add(ListingImageDraft(file: f));
          }
          if (_imageDrafts.length > 10) {
            _imageDrafts.removeRange(10, _imageDrafts.length);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        AppToast.showError(
          context,
          message: "Could not open the image picker.",
        );
      }
    }
  }

  void _addAmenity() {
    final v = _amenityCtrl.text.trim();
    if (v.isEmpty) return;
    if (!_amenities.contains(v)) {
      setState(() => _amenities.add(v));
    }
    _amenityCtrl.clear();
  }

  void _togglePresetAmenity(String amenity) {
    setState(() {
      if (_amenities.contains(amenity)) {
        _amenities.remove(amenity);
      } else {
        _amenities.add(amenity);
      }
    });
  }

  void _addUrlImage() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.surface,
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
              const Text(
                "Add image URL",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  hintText: "https://...",
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: "Add",
                width: double.infinity,
                onPressed: () {
                  final u = ctrl.text.trim();
                  if (u.isNotEmpty) {
                    setState(() => _imageDrafts.add(ListingImageDraft(url: u)));
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTagPickerModal(ListingImageDraft draft) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tag Room / Space",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Select what room or area this photo shows so it appears on the listing's Spaces section.",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._kRoomTagOptions.map((opt) {
                    final isSelected = draft.tag == opt['tag'];
                    return ChoiceChip(
                      label: Text("${opt['icon']}  ${opt['label']}"),
                      selected: isSelected,
                      selectedColor: AppColors.accent,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceAlt
                          : AppColors.surfaceAlt,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          draft.tag = selected ? opt['tag'] : null;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                  if (draft.tag != null)
                    ActionChip(
                      avatar: const Icon(LucideIcons.x, size: 14),
                      label: const Text("Remove Tag"),
                      onPressed: () {
                        setState(() => draft.tag = null);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final landlord = context.read<LandlordProvider>();

    final List<Map<String, dynamic>> finalImages = [];
    if (_imageDrafts.isNotEmpty) {
      setState(() => _uploadingImages = true);
      for (final draft in _imageDrafts) {
        String? finalUrl = draft.url;
        if (draft.isLocal && draft.file != null) {
          final uploaded = await landlord.uploadPropertyImages([draft.file!]);
          if (uploaded.isNotEmpty) {
            finalUrl = uploaded.first;
          }
        }
        if (finalUrl != null && finalUrl.isNotEmpty) {
          final item = <String, dynamic>{'url': finalUrl};
          if (draft.tag != null && draft.tag!.isNotEmpty) {
            item['tag'] = draft.tag;
          }
          if (draft.caption != null && draft.caption!.isNotEmpty) {
            item['caption'] = draft.caption;
          }
          finalImages.add(item);
        }
      }
      if (!mounted) return;
      setState(() => _uploadingImages = false);
    }

    // fallback for missing text
    if (_titleCtrl.text.isEmpty) {
       _titleCtrl.text = "\${_type[0].toUpperCase()}\${_type.substring(1)} in \${_cityCtrl.text}";
    }

    final body = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'type': _type,
      if (_type == 'hostel') 'hostel_type': _hostelType,
      'rent_amount': double.tryParse(_rentCtrl.text.trim()) ?? 0,
      'rent_period': _rentPeriod,
      if (_depositCtrl.text.trim().isNotEmpty)
        'security_deposit': double.tryParse(_depositCtrl.text.trim()),
      if (_type != 'hostel') ...{
        'bedrooms': int.tryParse(_bedroomsCtrl.text.trim()),
        'bathrooms': double.tryParse(_bathroomsCtrl.text.trim()),
      },
      'sqft': int.tryParse(_sqftCtrl.text.trim()) ?? 0,
      if (_houseNoCtrl.text.trim().isNotEmpty)
        'house_number': _houseNoCtrl.text.trim(),
      if (_streetCtrl.text.trim().isNotEmpty)
        'street_name': _streetCtrl.text.trim(),
      'address': _streetCtrl.text.trim().isNotEmpty
          ? [(_houseNoCtrl.text.trim()), (_streetCtrl.text.trim())]
              .where((s) => s.isNotEmpty)
              .join(", ")
          : _streetCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _state,
      'available_from': _formatDate(_availableFrom),
      'lease_term': _leaseTermCtrl.text.trim(),
      'contact_phone': _contactPhoneCtrl.text.trim(),
      'listed_by_type': 'direct_landlord',
      'amenities': _amenities,
      'images': finalImages,
    };

    final Property? result = _isEditing
        ? await landlord.updateListing(widget.existing!.id, body)
        : await landlord.createListing(body);

    if (!mounted) return;

    if (result != null) {
      AppToast.showSuccess(
        context,
        message: _isEditing
            ? "Listing updated successfully."
            : "Property listed successfully!",
      );
      Navigator.pop(context, true);
    } else {
      AppToast.showError(
        context,
        message: landlord.apiError ?? "Failed to save listing. Please try again.",
      );
    }
  }

  void _nextStep() {
    if (_currentStep == _totalSteps) {
      _submit();
    } else {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTopBar(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  "Save & exit",
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {}, // Questions hook
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  "Questions?",
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider underneath
        Container(
          height: 1,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        // Progress bar
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          tween: Tween<double>(
            begin: 0,
            end: (_currentStep == 0) ? 0.0 : (_currentStep / _totalSteps),
          ),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
              color: AppColors.primary,
              minHeight: 2,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > (_isEditing ? 1 : 0))
              TextButton(
                onPressed: _prevStep,
                child: Text(
                  "Back",
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            ElevatedButton(
              onPressed: _uploadingImages ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                minimumSize: const Size(140, 52),
              ),
              child: _uploadingImages
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentStep == _totalSteps
                          ? (_isEditing ? "Save changes" : "Publish listing")
                          : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "🏠",
              style: TextStyle(fontSize: 120),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Step 1",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tell us about your place",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "In this step, we'll ask you which type of property you have and if guests will book the entire place or just a room.",
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String value, String label, String icon, bool isDark) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.darkPrimary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostelTypeCard(String value, String label, String icon, bool isDark) {
    final isSelected = _hostelType == value;
    return GestureDetector(
      onTap: () => setState(() => _hostelType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.darkPrimary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Which of these best describes your place?",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildTypeCard("apartment", "Apartment / Flat", "🏢", isDark),
              _buildTypeCard("house", "House / Duplex", "🏡", isDark),
              _buildTypeCard("hostel", "Hostel", "🏨", isDark),
            ],
          ),
          if (_type == 'hostel') ...[
            const SizedBox(height: 32),
            const Text(
              "What type of hostel?",
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildHostelTypeCard("single_room", "Single Room", "🛏", isDark),
                _buildHostelTypeCard("self_contained", "Self-contained", "🛋️", isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepper(String label, TextEditingController ctrl, {double min = 0, double max = 20, double step = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double currentVal = double.tryParse(ctrl.text) ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: currentVal <= min
                    ? null
                    : () {
                        setState(() {
                          currentVal -= step;
                          if (currentVal % 1 == 0) {
                            ctrl.text = currentVal.toInt().toString();
                          } else {
                            ctrl.text = currentVal.toString();
                          }
                        });
                      },
                icon: const Icon(LucideIcons.minus),
                style: IconButton.styleFrom(
                  shape: CircleBorder(
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 30,
                child: Text(
                  (currentVal % 1 == 0) ? currentVal.toInt().toString() : currentVal.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: currentVal >= max
                    ? null
                    : () {
                        setState(() {
                          currentVal += step;
                          if (currentVal % 1 == 0) {
                            ctrl.text = currentVal.toInt().toString();
                          } else {
                            ctrl.text = currentVal.toString();
                          }
                        });
                      },
                icon: const Icon(LucideIcons.plus),
                style: IconButton.styleFrom(
                  shape: CircleBorder(
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How many rooms does it have?",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          if (_type != 'hostel') ...[
            _buildStepper("Bedrooms", _bedroomsCtrl, max: 20),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
          ],
          _buildStepper("Bathrooms", _bathroomsCtrl, max: 20, step: 0.5),
          Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
          const SizedBox(height: 24),
          FormInputField(
            controller: _sqftCtrl,
            label: "Square footage (Optional)",
            hintText: "e.g. 900",
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Where's your place located?",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _state,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                items: NigeriaLocations.states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _state = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          FormInputField(
            controller: _cityCtrl,
            label: "City",
            hintText: "e.g. Ado-Ekiti",
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          FormInputField(
            controller: _streetCtrl,
            label: "Street name",
            hintText: "e.g. Adebayo Road",
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          FormInputField(
            controller: _houseNoCtrl,
            label: "House number (Optional)",
            hintText: "e.g. 12",
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Now, set your price",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          FormInputField(
            controller: _rentCtrl,
            label: "Rent (₦)",
            hintText: "e.g. 850000",
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _rentPeriod,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'annually', child: Text('Annually')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _rentPeriod = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          FormInputField(
            controller: _depositCtrl,
            label: "Security deposit (₦) - Optional",
            hintText: "e.g. 50000",
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStep5(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What does your place offer?",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _kPresetAmenities.map((amenity) {
              final isSelected = _amenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (_) => _togglePresetAmenity(amenity),
                selectedColor: AppColors.accent,
                backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            "Additional amenities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FormInputField(
                  controller: _amenityCtrl,
                  label: "Custom amenity",
                  hintText: "e.g. Gym, Pool",
                  isDark: isDark,
                  onSubmitted: (_) => _addAmenity(),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: CustomButton(
                  text: "Add",
                  isAmber: true,
                  height: 48,
                  onPressed: _addAmenity,
                ),
              ),
            ],
          ),
          if (_amenities.where((a) => !_kPresetAmenities.contains(a)).isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _amenities
                  .where((a) => !_kPresetAmenities.contains(a))
                  .map((a) {
                return Chip(
                  label: Text(a),
                  deleteIcon: const Icon(LucideIcons.x, size: 14),
                  onDeleted: () => setState(() => _amenities.remove(a)),
                  backgroundColor:
                      isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep6(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add some photos of your place",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Pick images",
                  isOutline: true,
                  icon: LucideIcons.image_plus,
                  height: 52,
                  onPressed: _pickImages,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: "Add URL",
                  isOutline: true,
                  isAmber: true,
                  icon: LucideIcons.link,
                  height: 52,
                  onPressed: _addUrlImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_imageDrafts.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _imageDrafts
                  .map((draft) => _imageDraftThumb(draft, isDark))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _imageDraftThumb(ListingImageDraft draft, bool isDark) {
    final tagInfo = _kRoomTagOptions.firstWhere(
      (opt) => opt['tag'] == draft.tag,
      orElse: () => const {},
    );
    final hasTag = tagInfo.isNotEmpty;

    return Container(
      width: 105,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTag
              ? (isDark ? AppColors.darkAccent : AppColors.accent)
              : (isDark ? AppColors.darkBorder : AppColors.border),
          width: hasTag ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: SizedBox(
                  width: 105,
                  height: 75,
                  child: draft.isLocal
                      ? Image.file(File(draft.file!.path), fit: BoxFit.cover)
                      : Image.network(
                          draft.url ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              const Icon(LucideIcons.image_off),
                        ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _imageDrafts.remove(draft)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _showTagPickerModal(draft),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: hasTag
                    ? (isDark
                        ? AppColors.darkAccent.withValues(alpha: 0.2)
                        : AppColors.accent.withValues(alpha: 0.1))
                    : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasTag ? "${tagInfo['icon']}" : "🏷️",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      hasTag
                          ? (tagInfo['label'] ?? '').split(' ').first
                          : "Tag Room",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: hasTag
                            ? (isDark
                                ? AppColors.darkAccent
                                : AppColors.accent)
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Almost done!",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Available from",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _availableFrom,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() => _availableFrom = picked);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('d MMM yyyy').format(_availableFrom),
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FormInputField(
            controller: _leaseTermCtrl,
            label: "Lease term (Optional)",
            hintText: "e.g. 12-24 months",
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          FormInputField(
            controller: _contactPhoneCtrl,
            label: "Contact phone",
            hintText: "e.g. 0803 123 4567",
            isDark: isDark,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          FormInputField(
            controller: _titleCtrl,
            label: "Listing Title (Optional)",
            hintText: "e.g. Modern 2-Bedroom Flat",
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          FormInputField(
            controller: _descCtrl,
            label: "Description (Optional)",
            hintText: "Describe your property...",
            isDark: isDark,
            minLines: 3,
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTopBar(isDark),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep0(),
                    _buildStep1(isDark),
                    _buildStep2(isDark),
                    _buildStep3(isDark),
                    _buildStep4(isDark),
                    _buildStep5(isDark),
                    _buildStep6(isDark),
                    _buildStep7(isDark),
                  ],
                ),
              ),
              _buildBottomBar(isDark),
            ],
          ),
        ),
      ),
    );
  }
}
