import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/nigeria_locations.dart';
import '../../providers/user_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/inputs/custom_input_field.dart';
import '../../widgets/inputs/form_input_field.dart';
import '../auth/login.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;

  late String _selectedAvatar;
  late String _selectedState;
  late String _selectedLga;
  bool _isSaving = false;
  bool _isFetchingBackendData = false;
  bool _isUploadingPhoto = false;
  String? _editingSection;

  Map<String, List<String>> get _stateLgaMap => NigeriaLocations.lgaMap;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _firstNameController = TextEditingController(text: userProvider.firstName);
    _lastNameController = TextEditingController(text: userProvider.lastName);
    _phoneController = TextEditingController(text: userProvider.phone);
    _occupationController = TextEditingController(text: userProvider.bio);

    _selectedAvatar = userProvider.avatarUrl;

    // Set initial State
    final currentState = userProvider.userState;
    if (_stateLgaMap.containsKey(currentState)) {
      _selectedState = currentState;
    } else {
      _selectedState = "Lagos";
    }

    // Set initial LGA
    final lgas = _stateLgaMap[_selectedState]!;
    final currentLga = userProvider.lga;
    if (lgas.contains(currentLga)) {
      _selectedLga = currentLga;
    } else {
      _selectedLga = lgas.first;
    }

    // Fetch fresh profile directly from backend API
    _fetchFreshBackendProfile();
  }

  Future<void> _fetchFreshBackendProfile() async {
    setState(() {
      _isFetchingBackendData = true;
    });

    final userProvider = context.read<UserProvider>();
    // Reload from GET /profile (full field set) — GET /me omits
    // mobile/state/lga/occupation, which is why saved values used to revert.
    await userProvider.fetchFullProfile();

    if (!mounted) return;

    setState(() {
      _firstNameController.text = userProvider.firstName;
      _lastNameController.text = userProvider.lastName;
      _phoneController.text = userProvider.phone;
      _occupationController.text = userProvider.bio;
      _selectedAvatar = userProvider.avatarUrl;

      final currentState = userProvider.userState;
      if (_stateLgaMap.containsKey(currentState)) {
        _selectedState = currentState;
      }
      final lgas = _stateLgaMap[_selectedState] ?? [];
      final currentLga = userProvider.lga;
      if (lgas.contains(currentLga)) {
        _selectedLga = currentLga;
      }
      _isFetchingBackendData = false;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  // Step 1: Pick Image from Camera/Gallery
  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.pop(context); // Close source selector modal
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;
      if (!mounted) return;

      // Step 2: Show Image Preview & Guidelines Dialog before uploading
      _showImagePreviewDialog(pickedFile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to select image. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAvatarPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Upload Profile Photo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Select a photo from your gallery or take a new picture using your camera.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Camera option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                leading: Icon(
                  LucideIcons.camera,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  size: 22,
                ),
                title: Text(
                  "Take Photo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "Use camera to snap a new picture",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevron_right,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                onTap: () => _pickPhoto(ImageSource.camera),
              ),

              const SizedBox(height: 12),

              // Gallery option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                leading: Icon(
                  LucideIcons.image,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  size: 22,
                ),
                title: Text(
                  "Choose from Gallery",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "Select photo from device library",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevron_right,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                onTap: () => _pickPhoto(ImageSource.gallery),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Preview Dialog with Photo Guidelines (matching page.tsx)
  void _showImagePreviewDialog(XFile pickedFile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isModalUploading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Preview Profile Picture",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Review your photo before uploading",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image Preview Frame
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: FutureBuilder<Uint8List>(
                            future: pickedFile.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  height: 180,
                                  width: 180,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(
                                height: 180,
                                width: 180,
                                color: isDark
                                    ? AppColors.darkSurfaceAlt
                                    : AppColors.surfaceAlt,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Photo Guidelines Container (from page.tsx)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  LucideIcons.info,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Photo Guidelines",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _guidelineBullet(
                              "Your face is well-lit, not blurry, and fills the frame",
                              isDark,
                            ),
                            _guidelineBullet(
                              "You're facing forward and are the only person in your photo",
                              isDark,
                            ),
                            _guidelineBullet(
                              "Your photo doesn't feature animals or landscapes instead of you",
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isModalUploading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isModalUploading
                                  ? null
                                  : () async {
                                      setModalState(
                                        () => isModalUploading = true,
                                      );
                                      setState(() => _isUploadingPhoto = true);

                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final navigator = Navigator.of(
                                        dialogContext,
                                      );
                                      final userProvider = context
                                          .read<UserProvider>();
                                      final res = await userProvider
                                          .uploadAvatarFile(pickedFile);

                                      if (!mounted) return;

                                      setState(() {
                                        _selectedAvatar =
                                            userProvider.avatarUrl;
                                        _isUploadingPhoto = false;
                                      });

                                      navigator.pop();

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                res.success
                                                    ? LucideIcons.circle_check
                                                    : LucideIcons.circle_alert,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  res.message,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: res.success
                                              ? AppColors.primary
                                              : Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: isModalUploading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Upload Photo",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _guidelineBullet(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveProfile({String? sectionId}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: _selectedAvatar,
      state: _selectedState,
      lga: _selectedLga,
      bio: _occupationController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (success) {
        _editingSection = null;
      }
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.circle_check, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Saved successfully!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save. Please try again."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildInlineSection({
    required String sectionId,
    required String title,
    required String subtext,
    required String displayValue,
    required Widget editFormContent,
    required VoidCallback onSave,
    required bool isDark,
    bool hideAction = false,
  }) {
    final isEditing = _editingSection == sectionId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF222222),
                    ),
                  ),
                  if (subtext.isNotEmpty && isEditing) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF717171),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!hideAction) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isEditing) {
                      _editingSection = null;
                    } else {
                      _editingSection = sectionId;
                    }
                  });
                },
                child: Text(
                  isEditing
                      ? "Cancel"
                      : (displayValue == "Not provided" ? "Add" : "Edit"),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        if (!isEditing)
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 15,
              fontWeight: displayValue == "Not provided"
                  ? FontWeight.normal
                  : FontWeight.w500,
              color: displayValue == "Not provided"
                  ? (isDark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF717171))
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF222222)),
            ),
          )
        else ...[
          const SizedBox(height: 12),
          editFormContent,
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkAccent
                    : const Color(0xFF222222),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : const Color(0xFFEBEBEB),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccountInlineSection({
    required String sectionId,
    required String title,
    required String subtext,
    required String displayValue,
    required Widget actionContent,
    required VoidCallback onSave,
    required bool isDark,
    bool hideAction = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF222222),
                    ),
                  ),
                  if (subtext.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF717171),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!hideAction) ...[actionContent],
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : const Color(0xFFEBEBEB),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final lgaList = _stateLgaMap[_selectedState] ?? [];

    final fullName = "${userProvider.firstName} ${userProvider.lastName}"
        .trim();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          "Account settings",
          style: TextStyle(
            fontSize: AppFontSizes.titleLarge,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        bottom: _isFetchingBackendData
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  color: isDark ? AppColors.darkAccent : AppColors.primary,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFreshBackendProfile,
          color: isDark ? AppColors.darkAccent : AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy Info Card
                  _buildInfoCard(
                    icon: LucideIcons.eye,
                    title: "Privacy Info",
                    description:
                        "Only your full name, location, phone number, and occupation are shared with property owners and agents.",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  // Profile Photo Header
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.white.withValues(alpha: 0.3)
                                  : AppColors.border,
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 46,
                                backgroundImage: NetworkImage(_selectedAvatar),
                              ),
                              if (_isUploadingPhoto)
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.white.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.camera,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Text(
                        "Change photo",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section Title: Personal Info
                  Text(
                    "Personal info",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Legal Name Section
                  _buildInlineSection(
                    sectionId: "legal_name",
                    title: "Legal name",
                    subtext:
                        "This is the name on your official travel document, like your passport or driver's license.",
                    displayValue: fullName.isNotEmpty
                        ? fullName
                        : "Not provided",
                    isDark: isDark,
                    onSave: () => _handleSaveProfile(sectionId: "legal_name"),
                    editFormContent: Column(
                      children: [
                        CustomInputField(
                          controller: _firstNameController,
                          hintText: "First Name",
                          isDark: isDark,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "First name required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomInputField(
                          controller: _lastNameController,
                          hintText: "Last Name",
                          isDark: isDark,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Last name required"
                              : null,
                        ),
                      ],
                    ),
                  ),

                  // 2. Phone Number Section
                  _buildInlineSection(
                    sectionId: "phone",
                    title: "Phone number",
                    subtext:
                        "Add a number so confirmed agents and landlords can get in touch.",
                    displayValue: userProvider.phone.isNotEmpty
                        ? userProvider.phone
                        : "Not provided",
                    isDark: isDark,
                    onSave: () => _handleSaveProfile(sectionId: "phone"),
                    editFormContent: CustomInputField(
                      controller: _phoneController,
                      hintText: "Phone Number",
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().length < 10
                          ? "Valid phone number required"
                          : null,
                    ),
                  ),

                  // 3. Email Section (Read only / verified)
                  _buildInlineSection(
                    sectionId: "email",
                    title: "Email address",
                    subtext: "Use an address you'll always have access to.",
                    displayValue: userProvider.email.isNotEmpty
                        ? userProvider.email
                        : "Not provided",
                    isDark: isDark,
                    hideAction: true,
                    onSave: () {},
                    editFormContent: const SizedBox.shrink(),
                  ),

                  // 4. Occupation Section
                  _buildInlineSection(
                    sectionId: "occupation",
                    title: "Occupation",
                    subtext:
                        "Your profession or bio displayed on your profile.",
                    displayValue: userProvider.bio.isNotEmpty
                        ? userProvider.bio
                        : "Not provided",
                    isDark: isDark,
                    onSave: () => _handleSaveProfile(sectionId: "occupation"),
                    editFormContent: CustomInputField(
                      controller: _occupationController,
                      hintText: "Occupation",
                      isDark: isDark,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),

                  // 5. Location Section
                  _buildInlineSection(
                    sectionId: "location",
                    title: "Location (State & LGA)",
                    subtext: "Your current state and LGA of residence.",
                    displayValue: "$_selectedLga, $_selectedState",
                    isDark: isDark,
                    onSave: () => _handleSaveProfile(sectionId: "location"),
                    editFormContent: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedState,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF222222),
                          ),
                          decoration: _inlineInputDecoration(
                            hintText: "Select State",
                            isDark: isDark,
                          ),
                          dropdownColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.surface,
                          items: _stateLgaMap.keys.map((st) {
                            return DropdownMenuItem(
                              value: st,
                              child: Text(
                                st,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : const Color(0xFF222222),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedState = val;
                                final newLgas = _stateLgaMap[val]!;
                                _selectedLga = newLgas.first;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: lgaList.contains(_selectedLga)
                              ? _selectedLga
                              : (lgaList.isNotEmpty ? lgaList.first : null),
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF222222),
                          ),
                          decoration: _inlineInputDecoration(
                            hintText: "Select LGA",
                            isDark: isDark,
                          ),
                          dropdownColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.surface,
                          items: lgaList.map((lg) {
                            return DropdownMenuItem(
                              value: lg,
                              child: Text(
                                lg,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : const Color(0xFF222222),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedLga = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section Title: Security & Password
                  Text(
                    "Account management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Password Section
                  _buildAccountInlineSection(
                    sectionId: "password",
                    title: "Password",
                    subtext: "Change your password",
                    displayValue: "",
                    isDark: isDark,
                    onSave: () => _handleSaveProfile(sectionId: "password"),
                    actionContent: InkWell(
                      onTap: () =>
                          _showChangePasswordModal(context, userProvider),
                      child: Text(
                        "Change",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),

                  _buildAccountInlineSection(
                    sectionId: "deactivate_account",
                    title: "Deactivate Account",
                    subtext: "Deactivate your account",
                    displayValue: "",
                    isDark: isDark,
                    onSave: () =>
                        _handleSaveProfile(sectionId: "deactivate_account"),
                    actionContent: InkWell(
                      onTap: () =>
                          _showDeactivateAccountDialog(context, userProvider),
                      child: Text(
                        "Deactivate",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // CHANGE PASSWORD MODAL
  void _showChangePasswordModal(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    bool isSubmitting = false;
    String? errorMessage;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Icon(
                              LucideIcons.lock,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        FormInputField(
                          controller: currentPasswordController,
                          label: "Current Password",
                          hintText: "Enter current password",
                          obscureText: obscureCurrent,
                          isDark: isDark,
                          prefixIcon: LucideIcons.lock,
                          customSuffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? LucideIcons.eye_off
                                  : LucideIcons.eye,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () => setModalState(
                              () => obscureCurrent = !obscureCurrent,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? "Current password is required"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        FormInputField(
                          controller: newPasswordController,
                          label: "New Password",
                          hintText: "At least 6 characters",
                          obscureText: obscureNew,
                          isDark: isDark,
                          prefixIcon: LucideIcons.lock,
                          customSuffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? LucideIcons.eye_off
                                  : LucideIcons.eye,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                setModalState(() => obscureNew = !obscureNew),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "New password is required";
                            }
                            if (v.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        FormInputField(
                          controller: confirmPasswordController,
                          label: "Confirm New Password",
                          hintText: "Re-enter new password",
                          obscureText: obscureConfirm,
                          isDark: isDark,
                          prefixIcon: LucideIcons.lock,
                          customSuffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? LucideIcons.eye_off
                                  : LucideIcons.eye,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () => setModalState(
                              () => obscureConfirm = !obscureConfirm,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please confirm password";
                            }
                            if (v != newPasswordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.darkAccent
                                      : AppColors.primary,
                                  foregroundColor: isDark
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }

                                        setModalState(() {
                                          isSubmitting = true;
                                          errorMessage = null;
                                        });

                                        final res = await userProvider
                                            .changePassword(
                                              currentPassword:
                                                  currentPasswordController
                                                      .text,
                                              newPassword:
                                                  newPasswordController.text,
                                            );

                                        if (!context.mounted) return;

                                        if (res.success) {
                                          Navigator.pop(context);
                                          AppToast.showSuccess(
                                            context,
                                            message:
                                                "Password updated successfully!",
                                          );
                                        } else {
                                          setModalState(() {
                                            isSubmitting = false;
                                            errorMessage = res.message;
                                          });
                                        }
                                      },
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Save",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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
            );
          },
        );
      },
    );
  }

  // DEACTIVATE ACCOUNT DIALOG
  void _showDeactivateAccountDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasonController = TextEditingController();
    bool isDeactivating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.triangle_alert,
                            color: isDark ? AppColors.darkAccent : Colors.red,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Deactivate Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "Are you sure you want to deactivate your account? Your profile will be hidden, and you will be signed out.",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      FormInputField(
                        controller: reasonController,
                        label: "Reason for leaving (Optional):",
                        hintText: "e.g. Found a house, no longer need account",
                        isDark: isDark,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isDeactivating
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isDeactivating
                                  ? null
                                  : () async {
                                      setDialogState(
                                        () => isDeactivating = true,
                                      );

                                      final res = await userProvider
                                          .deactivateAccount(
                                            reason: reasonController.text
                                                .trim(),
                                          );

                                      if (!context.mounted) return;

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(res.message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );

                                      context
                                          .read<PropertyProvider>()
                                          .clearFavorites();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                              child: isDeactivating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Deactivate",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.white : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inlineInputDecoration({
    required String hintText,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontFamily: 'Satoshi',
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        fontSize: 15,
      ),
      suffixIcon: suffixIcon,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.white : AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}
