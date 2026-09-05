import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/property_model.dart';
import '../../providers/landlord_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/inputs/custom_input_field.dart';
import 'add_edit_property.dart'; // For ListingImageDraft

/// Photo tour management screen mirroring the Airbnb host photo tour flow.
/// Shows photos categorized by room (Bedroom, Bathroom, Living Room, etc.) with
/// visual cards, room tags, and direct image upload / removal.
class PhotoTourScreen extends StatefulWidget {
  final Property property;
  final ValueChanged<Property>? onPropertyUpdated;

  const PhotoTourScreen({
    super.key,
    required this.property,
    this.onPropertyUpdated,
  });

  @override
  State<PhotoTourScreen> createState() => _PhotoTourScreenState();
}

class _PhotoTourScreenState extends State<PhotoTourScreen> {
  late Property _property;
  final _picker = ImagePicker();
  bool _isUploading = false;
  late List<ListingImageDraft> _drafts;

  final List<Map<String, dynamic>> _roomCategories = [
    {
      "tag": "bedroom",
      "label": "Bedroom",
      "icon": "🛏️",
      "desc": "Bed, wardrobe, lighting",
    },
    {
      "tag": "bathroom",
      "label": "Full bathroom",
      "icon": "🛁",
      "desc": "Shower, toilet, sink",
    },
    {
      "tag": "living_room",
      "label": "Living Room (Parlour)",
      "icon": "🛋️",
      "desc": "Seating, TV, dining",
    },
    {
      "tag": "kitchen",
      "label": "Kitchen",
      "icon": "🍳",
      "desc": "Cabinets, sink, cooker",
    },
    {
      "tag": "exterior",
      "label": "Compound & Exterior",
      "icon": "🏡",
      "desc": "Gate, parking space, building",
    },
    {
      "tag": "balcony",
      "label": "Balcony / Veranda",
      "icon": "🌅",
      "desc": "Terrace, outdoor view",
    },
  ];

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    _syncDraftsFromProperty();
  }

  void _syncDraftsFromProperty() {
    _drafts = [];
    if (_property.propertyImages.isNotEmpty) {
      for (final img in _property.propertyImages) {
        if (img.url.isNotEmpty) {
          _drafts.add(ListingImageDraft(
            url: img.url,
            tag: img.tag,
            caption: img.caption,
          ));
        }
      }
    } else {
      for (final u in _property.gallery) {
        if (u.isNotEmpty) {
          _drafts.add(ListingImageDraft(url: u));
        }
      }
    }
  }

  List<ListingImageDraft> _getDraftsForTag(String tag) {
    return _drafts.where((d) => d.tag?.toLowerCase() == tag.toLowerCase()).toList();
  }

  List<ListingImageDraft> _getUntaggedDrafts() {
    return _drafts
        .where((d) => d.tag == null || d.tag!.trim().isEmpty || !_roomCategories.any((r) => r['tag'] == d.tag))
        .toList();
  }

  void _showAddPhotoOptions({String? initialTag}) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Photos",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    LucideIcons.image,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  title: const Text("Choose from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Select one or more photos from your device"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadImages(initialTag: initialTag);
                  },
                ),
                ListTile(
                  leading: Icon(
                    LucideIcons.link,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  title: const Text("Add by Image URL", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Paste a direct web link to an image"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _addUrlImageDialog(initialTag: initialTag);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImages({String? initialTag}) async {
    try {
      final picked = await _picker.pickMultiImage(limit: 10);
      if (picked.isEmpty) return;

      if (!mounted) return;
      setState(() => _isUploading = true);

      final landlord = context.read<LandlordProvider>();
      final uploadedUrls = await landlord.uploadPropertyImages(picked);

      if (!mounted) return;

      if (uploadedUrls.isEmpty) {
        AppToast.showError(context, message: "Failed to upload selected photos.");
        setState(() => _isUploading = false);
        return;
      }

      for (final url in uploadedUrls) {
        _drafts.add(ListingImageDraft(
          url: url,
          tag: initialTag,
        ));
      }

      await _persistPhotosToBackend();
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, message: "Could not open image picker.");
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _addUrlImageDialog({String? initialTag}) {
    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
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
              Text(
                "Add photo URL",
                style: TextStyle(
                  fontFamily: 'Cabinet Grotesk',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: ctrl,
                hintText: "https://...",
                isDark: isDark,
                prefixIcon: LucideIcons.link,
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: "Add photo",
                isPrimary: true,
                width: double.infinity,
                onPressed: () async {
                  final u = ctrl.text.trim();
                  if (u.isNotEmpty) {
                    Navigator.pop(ctx);
                    setState(() {
                      _drafts.add(ListingImageDraft(url: u, tag: initialTag));
                    });
                    await _persistPhotosToBackend();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _persistPhotosToBackend() async {
    final landlord = context.read<LandlordProvider>();
    final List<Map<String, dynamic>> finalImages = [];

    for (final draft in _drafts) {
      if (draft.url != null && draft.url!.isNotEmpty) {
        final item = <String, dynamic>{'url': draft.url};
        if (draft.tag != null && draft.tag!.isNotEmpty) {
          item['tag'] = draft.tag;
        }
        if (draft.caption != null && draft.caption!.isNotEmpty) {
          item['caption'] = draft.caption;
        }
        finalImages.add(item);
      }
    }

    final updated = await landlord.updateListing(_property.id, {
      'images': finalImages,
    });

    if (!mounted) return;

    if (updated != null) {
      setState(() {
        _property = updated;
        _syncDraftsFromProperty();
      });
      widget.onPropertyUpdated?.call(updated);
      AppToast.showSuccess(context, message: "Photo tour updated!");
    } else {
      AppToast.showError(context, message: "Failed to update photos.");
    }
  }

  void _showTagSelector(ListingImageDraft draft) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tag Room or Space",
                    style: TextStyle(
                      fontFamily: 'Cabinet Grotesk',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Categorizing photos by room gives prospective tenants an immersive 3D-like tour experience.",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._roomCategories.map((opt) {
                    final isSelected = draft.tag == opt['tag'];
                    return ChoiceChip(
                      label: Text("${opt['icon']}  ${opt['label']}"),
                      selected: isSelected,
                      selectedColor: isDark ? AppColors.darkAccent : AppColors.primary,
                      backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                      onSelected: (selected) async {
                        setState(() {
                          draft.tag = selected ? opt['tag'] : null;
                        });
                        Navigator.pop(ctx);
                        await _persistPhotosToBackend();
                      },
                    );
                  }),
                  if (draft.tag != null)
                    ActionChip(
                      avatar: const Icon(LucideIcons.x, size: 14),
                      label: const Text("Untag room"),
                      onPressed: () async {
                        setState(() => draft.tag = null);
                        Navigator.pop(ctx);
                        await _persistPhotosToBackend();
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

  void _showAllPhotosSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Photos (${_drafts.length})",
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.plus),
                            onPressed: () => _showAddPhotoOptions(),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _drafts.isEmpty
                        ? Center(
                            child: Text(
                              "No photos uploaded yet.",
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: _drafts.length,
                            itemBuilder: (context, i) {
                              final d = _drafts[i];
                              return _buildPhotoTile(d, isDark, onDelete: () async {
                                setState(() => _drafts.remove(d));
                                setModalState(() {});
                                await _persistPhotosToBackend();
                              });
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final untagged = _getUntaggedDrafts();

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
          onPressed: () => Navigator.pop(context, _property),
        ),
        title: Text(
          "Photo tour",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showAllPhotosSheet,
            icon: Icon(
              LucideIcons.images,
              size: 16,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
            label: Text(
              "All photos",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkAccent : AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.plus,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            onPressed: () => _showAddPhotoOptions(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Uploading photos...",
                    style: TextStyle(
                      fontFamily: 'Cabinet Grotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              children: [
                // Top subtitle
                Text(
                  "Manage photos and add room details. Categorized photos give prospective tenants an authentic walkthrough of the space.",
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Status task banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _drafts.isEmpty ? Colors.orange : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _drafts.isEmpty
                              ? "No photos added yet. Tap + to upload."
                              : "${_drafts.length} photo${_drafts.length == 1 ? '' : 's'} in tour (${_drafts.length - untagged.length} tagged)",
                          style: TextStyle(
                            fontFamily: 'Cabinet Grotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showAddPhotoOptions(),
                        child: const Text("Add photos"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Room categories grid
                Text(
                  "Rooms & Spaces",
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ..._roomCategories.map((room) {
                  final tag = room['tag'] as String;
                  final roomDrafts = _getDraftsForTag(tag);

                  return _buildRoomSectionCard(
                    room: room,
                    drafts: roomDrafts,
                    isDark: isDark,
                  );
                }),

                if (untagged.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Additional Photos (${untagged.length})",
                    style: TextStyle(
                      fontFamily: 'Cabinet Grotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: untagged.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final d = untagged[i];
                        return _buildPhotoTile(d, isDark, width: 140, onDelete: () async {
                          setState(() => _drafts.remove(d));
                          await _persistPhotosToBackend();
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildRoomSectionCard({
    required Map<String, dynamic> room,
    required List<ListingImageDraft> drafts,
    required bool isDark,
  }) {
    final hasPhotos = drafts.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(room['icon'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        hasPhotos ? "${drafts.length} photo(s)" : (room['desc'] as String),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddPhotoOptions(initialTag: room['tag'] as String),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: Text(hasPhotos ? "Add" : "Add photos"),
                ),
              ],
            ),
          ),

          // Photos preview row if photos exist
          if (hasPhotos)
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                scrollDirection: Axis.horizontal,
                itemCount: drafts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final d = drafts[i];
                  return _buildPhotoTile(d, isDark, width: 110, onDelete: () async {
                    setState(() => _drafts.remove(d));
                    await _persistPhotosToBackend();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(
    ListingImageDraft draft,
    bool isDark, {
    double? width,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: draft.isLocal
                  ? Image.file(File(draft.file!.path), fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: draft.url ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(LucideIcons.image_off, size: 24),
                      ),
                    ),
            ),
          ),

          // Tag room badge
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _showTagSelector(draft),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.tag, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        draft.tag != null && draft.tag!.isNotEmpty
                            ? draft.tag!.replaceAll('_', ' ').toUpperCase()
                            : "TAG ROOM",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Delete icon button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.trash_2,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
