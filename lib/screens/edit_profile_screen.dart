import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/nigeria_locations.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
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
                    Icons.camera_alt_rounded,
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
                  Icons.chevron_right_rounded,
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
                    Icons.photo_library_rounded,
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
                  Icons.chevron_right_rounded,
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
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.surface,
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
                                  Icons.info_outline_rounded,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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

                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      final navigator =
                                          Navigator.of(dialogContext);
                                      final userProvider =
                                          context.read<UserProvider>();
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
                                                    ? Icons.check_circle_rounded
                                                    : Icons.error_outline_rounded,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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

  Future<void> _handleSaveProfile() async {
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
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Profile updated successfully!",
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile. Please try again."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lgaList = _stateLgaMap[_selectedState] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
        elevation: 0,
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
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header Subtitle (matching page.tsx)
                  Text(
                    "Manage your personal information and preferences.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Cards Row (matching page.tsx Editable Fields & Privacy Info)
                  _buildInfoCard(
                    icon: Icons.info_outline_rounded,
                    title: "Editable Fields",
                    description:
                        "You can update your full name, profile picture, location (LGA, State), phone number, and occupation.",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.visibility_outlined,
                    title: "Privacy Info",
                    description:
                        "Only your full name, location, phone number, and occupation are shared with agents.",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Main Card Frame (matching page.tsx Personal Information section)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkLine : AppColors.line,
                      ),
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
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.terracotta,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Avatar Section
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
                                      backgroundImage: NetworkImage(
                                        _selectedAvatar,
                                      ),
                                    ),
                                    if (_isUploadingPhoto)
                                      Container(
                                        width: 92,
                                        height: 92,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
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
                                          color: AppColors.terracotta
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
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
                          child: Text(
                            "Click camera icon to update photo",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // First Name
                        Text("First Name", style: _labelStyle(isDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: "First Name",
                            icon: Icons.person_outline_rounded,
                            isDark: isDark,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "First name required"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        Text("Last Name", style: _labelStyle(isDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: "Last Name",
                            icon: Icons.person_outline_rounded,
                            isDark: isDark,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Last name required"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        Text("Phone Number", style: _labelStyle(isDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            hint: "Phone Number",
                            icon: Icons.phone_outlined,
                            isDark: isDark,
                          ),
                          validator: (v) => v == null || v.trim().length < 10
                              ? "Valid phone number required"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Occupation
                        Text("Occupation", style: _labelStyle(isDark)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _occupationController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: "Occupation",
                            icon: Icons.work_outline_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // State
                        Text("State", style: _labelStyle(isDark)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedState,
                          decoration: _inputDecoration(
                            hint: "Select State",
                            icon: Icons.map_outlined,
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
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkInk
                                      : AppColors.ink,
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
                        const SizedBox(height: 16),

                        // LGA / City
                        Text("LGA / City", style: _labelStyle(isDark)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: lgaList.contains(_selectedLga)
                              ? _selectedLga
                              : (lgaList.isNotEmpty ? lgaList.first : null),
                          decoration: _inputDecoration(
                            hint: "Select LGA",
                            icon: Icons.location_city_rounded,
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
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkInk
                                      : AppColors.ink,
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

                        const SizedBox(height: 28),

                        // Save Button
                        CustomButton(
                          text: _isSaving ? "Saving..." : "Save Changes",
                          width: double.infinity,
                          isTerracotta: true,
                          icon: Icons.save_rounded,
                          onPressed: _isSaving ? null : _handleSaveProfile,
                        ),
                      ],
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
        border: Border.all(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
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

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.darkInk : AppColors.ink,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? AppColors.darkMuted : AppColors.muted,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.forest, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
      ),
    );
  }
}
