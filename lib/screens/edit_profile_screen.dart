import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/nigeria_locations.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

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
    await userProvider.fetchMe();

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
                    color: isDark ? AppColors.darkLine : AppColors.line,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Upload Profile Photo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkInk : AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Select a photo from your gallery or take a new picture using your camera.",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
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
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    color: AppColors.terracotta,
                    size: 22,
                  ),
                ),
                title: Text(
                  "Take Photo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppColors.darkInk : AppColors.ink,
                  ),
                ),
                subtitle: Text(
                  "Use camera to snap a new picture",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevron_right,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
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
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.image,
                    color: AppColors.forest,
                    size: 22,
                  ),
                ),
                title: Text(
                  "Choose from Gallery",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppColors.darkInk : AppColors.ink,
                  ),
                ),
                subtitle: Text(
                  "Select photo from device library",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevron_right,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
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
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Review your photo before uploading",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
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
                                    : AppColors.creamAlt,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.terracotta,
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
                              : AppColors.creamAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkLine : AppColors.line,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  LucideIcons.info,
                                  color: AppColors.forest,
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
                                              ? AppColors.forest
                                              : Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.terracotta,
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
                color: isDark ? AppColors.darkMuted : AppColors.muted,
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
          backgroundColor: AppColors.forest,
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
                      color: isDark ? AppColors.darkInk : const Color(0xFF222222),
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
                            ? AppColors.darkMuted
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
                    color: isDark ? AppColors.darkInk : const Color(0xFF222222),
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
                  ? (isDark ? AppColors.darkMuted : const Color(0xFF717171))
                  : (isDark ? AppColors.darkInk : const Color(0xFF222222)),
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
                    ? AppColors.terracotta
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
          color: isDark ? AppColors.darkLine : const Color(0xFFEBEBEB),
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

    final fullName =
        "${userProvider.firstName} ${userProvider.lastName}".trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personal info",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkInk : const Color(0xFF222222),
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        bottom: _isFetchingBackendData
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  color: AppColors.terracotta,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFreshBackendProfile,
          color: AppColors.terracotta,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Header
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.terracotta.withValues(
                                alpha: 0.3,
                              ),
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
                                color: AppColors.terracotta,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.terracotta.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.camera,
                                color: Colors.white,
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
                              ? AppColors.darkInk
                              : const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 1. Legal Name Section
                  _buildInlineSection(
                    sectionId: "legal_name",
                    title: "Legal name",
                    subtext:
                        "This is the name on your official travel document, like your passport or driver's license.",
                    displayValue: fullName.isNotEmpty ? fullName : "Not provided",
                    isDark: isDark,
                    onSave: () => _handleSaveProfile(sectionId: "legal_name"),
                    editFormContent: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkInk
                                : const Color(0xFF222222),
                          ),
                          decoration: _airbnbInputDecoration(
                            labelText: "First name on ID",
                            hintText: "First Name",
                            isDark: isDark,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "First name required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkInk
                                : const Color(0xFF222222),
                          ),
                          decoration: _airbnbInputDecoration(
                            labelText: "Last name on ID",
                            hintText: "Last Name",
                            isDark: isDark,
                          ),
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
                    editFormContent: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkInk
                            : const Color(0xFF222222),
                      ),
                      decoration: _airbnbInputDecoration(
                        labelText: "Phone number",
                        hintText: "Phone Number",
                        isDark: isDark,
                      ),
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
                    editFormContent: TextFormField(
                      controller: _occupationController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkInk
                            : const Color(0xFF222222),
                      ),
                      decoration: _airbnbInputDecoration(
                        labelText: "Occupation",
                        hintText: "Occupation",
                        isDark: isDark,
                      ),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkInk
                                : const Color(0xFF222222),
                          ),
                          decoration: _airbnbInputDecoration(
                            labelText: "State of Residence",
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkInk
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkInk
                                : const Color(0xFF222222),
                          ),
                          decoration: _airbnbInputDecoration(
                            labelText: "LGA / City",
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkInk
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

                  const SizedBox(height: 12),

                  // Privacy Info Card
                  _buildInfoCard(
                    icon: LucideIcons.eye,
                    title: "Privacy Info",
                    description:
                        "Only your full name, location, phone number, and occupation are shared with verified property agents.",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.terracotta, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkInk : AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _airbnbInputDecoration({
    required String labelText,
    required String hintText,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      alignLabelWithHint: true,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkMuted : const Color(0xFF717171),
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkMuted : const Color(0xFF717171),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark
            ? AppColors.darkMuted.withValues(alpha: 0.5)
            : const Color(0xFFB0B0B0),
        fontSize: 15,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : const Color(0xFFB0B0B0),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : const Color(0xFFB0B0B0),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.terracotta : const Color(0xFF222222),
          width: 1.8,
        ),
      ),
    );
  }
}
