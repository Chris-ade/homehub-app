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

/// Full-screen form for creating or editing a property listing, wired to the
/// backend's POST/PUT /listings endpoints. In add mode it's blank; in edit mode
/// it pre-fills from [existing] and PUTs to the same id.
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

  @override
  void initState() {
    super.initState();
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
    }
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final landlord = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Property" : "List a New Property"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel("Basic details", isDark),
              FormInputField(
                controller: _titleCtrl,
                label: "Property title *",
                hintText: "e.g. Modern 2-Bedroom Flat",
                isDark: isDark,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 14),
              FormInputField(
                controller: _descCtrl,
                label: "Description",
                hintText: "Describe your property...",
                isDark: isDark,
                minLines: 2,
                maxLines: 5,
              ),

              const SizedBox(height: 16),
              _sectionLabel("Type & pricing", isDark),
              _dropdown<DropdownMenuEntry<String>, String>(
                label: "Property type *",
                isDark: isDark,
                items: [
                  DropdownMenuEntry(value: 'apartment', label: 'Apartment / Flat'),
                  DropdownMenuEntry(value: 'house', label: 'House / Duplex'),
                  DropdownMenuEntry(value: 'hostel', label: 'Hostel / Self-contained'),
                ],
                value: _type,
                onChanged: (v) => setState(() => _type = v),
              ),
              if (_type == 'hostel') ...[
                const SizedBox(height: 12),
                _dropdown<DropdownMenuEntry<String>, String>(
                  label: "Hostel type *",
                  isDark: isDark,
                  items: [
                    DropdownMenuEntry(value: 'single_room', label: 'Single Room'),
                    DropdownMenuEntry(value: 'self_contained', label: 'Self-contained'),
                  ],
                  value: _hostelType ?? 'single_room',
                  onChanged: (v) => setState(() => _hostelType = v),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormInputField(
                      controller: _rentCtrl,
                      label: "Rent (₦) *",
                      hintText: "e.g. 850000",
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Required"
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormInputField(
                      controller: _depositCtrl,
                      label: "Security deposit",
                      hintText: "Optional",
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _dropdown<DropdownMenuEntry<String>, String>(
                label: "Rent period *",
                isDark: isDark,
                items: [
                  DropdownMenuEntry(value: 'monthly', label: 'Monthly'),
                  DropdownMenuEntry(value: 'annually', label: 'Annually'),
                ],
                value: _rentPeriod,
                onChanged: (v) => setState(() => _rentPeriod = v),
              ),

              const SizedBox(height: 16),
              _sectionLabel("Property details", isDark),
              if (_type != 'hostel') ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FormInputField(
                        controller: _bedroomsCtrl,
                        label: "Bedrooms *",
                        hintText: "e.g. 2",
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Required"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormInputField(
                        controller: _bathroomsCtrl,
                        label: "Bathrooms *",
                        hintText: "e.g. 2 or 1.5",
                        isDark: isDark,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Required"
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              FormInputField(
                controller: _sqftCtrl,
                label: "Square footage",
                hintText: "e.g. 900",
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              _sectionLabel("Location", isDark),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: FormInputField(
                      controller: _cityCtrl,
                      label: "City *",
                      hintText: "e.g. Ado-Ekiti",
                      isDark: isDark,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "City is required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _dropdown<DropdownMenuEntry<String>, String>(
                      label: "State",
                      isDark: isDark,
                      items: NigeriaLocations.states
                          .map((s) => DropdownMenuEntry(value: s, label: s))
                          .toList(),
                      value: _state,
                      onChanged: (v) => setState(() => _state = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormInputField(
                controller: _streetCtrl,
                label: "Street name",
                hintText: "e.g. Adebayo Road",
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              FormInputField(
                controller: _houseNoCtrl,
                label: "House number",
                hintText: "e.g. 12",
                isDark: isDark,
              ),

              const SizedBox(height: 16),
              _sectionLabel("Availability & contact", isDark),
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
                child: InputDecorator(
                  decoration: _deco(isDark, "Available from"),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('d MMM yyyy').format(_availableFrom),
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FormInputField(
                controller: _leaseTermCtrl,
                label: "Lease term",
                hintText: "e.g. 12-24 months",
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              FormInputField(
                controller: _contactPhoneCtrl,
                label: "Contact phone *",
                hintText: "e.g. 0803 123 4567",
                isDark: isDark,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Phone is required" : null,
              ),

              const SizedBox(height: 16),
              _sectionLabel("Amenities", isDark),
              Row(
                children: [
                  Expanded(
                    child: FormInputField(
                      controller: _amenityCtrl,
                      label: "Add amenity",
                      hintText: "e.g. Water, Security, Parking",
                      isDark: isDark,
                      onSubmitted: (_) => _addAmenity(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: CustomButton(
                      text: "Add",
                      isAmber: true,
                      height: 44,
                      onPressed: _addAmenity,
                    ),
                  ),
                ],
              ),
              if (_amenities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _amenities.map((a) {
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

              const SizedBox(height: 16),
              _sectionLabel("Photos", isDark),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Pick images",
                      isOutline: true,
                      icon: LucideIcons.image_plus,
                      height: 44,
                      onPressed: _pickImages,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: "Add URL",
                      isOutline: true,
                      isAmber: true,
                      icon: LucideIcons.link,
                      height: 44,
                      onPressed: _addUrlImage,
                    ),
                  ),
                ],
              ),
              if (_imageDrafts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _imageDrafts
                      .map((draft) => _imageDraftThumb(draft, isDark))
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),
              CustomButton(
                text: _uploadingImages
                    ? "Uploading images..."
                    : (_isEditing
                        ? "Save changes"
                        : "Publish listing"),
                isAmber: true,
                width: double.infinity,
                isDisabled: landlord.isSubmitting || _uploadingImages,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
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
                top: 3,
                right: 3,
                child: GestureDetector(
                  onTap: () => setState(() => _imageDrafts.remove(draft)),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _showTagPickerModal(draft),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(11)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              decoration: BoxDecoration(
                color: hasTag
                    ? (isDark
                        ? AppColors.darkAccent.withValues(alpha: 0.2)
                        : AppColors.accent.withValues(alpha: 0.1))
                    : Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasTag ? "${tagInfo['icon']}" : "🏷️",
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(width: 3),
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

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDark ? AppColors.darkAccent : AppColors.accent,
        ),
      ),
    );
  }

  InputDecoration _deco(bool isDark, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  /// Builds a labelled dropdown. [T] is the DropdownMenuEntry type, [V] the value.
  Widget _dropdown<T, V>({
    required String label,
    required bool isDark,
    required List<DropdownMenuEntry<V>> items,
    required V value,
    required ValueChanged<V> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownMenu<V>(
          initialSelection: value,
          dropdownMenuEntries: items,
          onSelected: (v) {
            if (v != null) onChanged(v);
          },
          expandedInsets: EdgeInsets.zero,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          ),
          textStyle: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
