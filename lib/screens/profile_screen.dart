import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/app_theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_property_modal.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_verification_modal.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<AppThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkInk : const Color(0xFF222222),
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? AppColors.darkInk : const Color(0xFF222222),
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.fetchMe();
        },
        color: AppColors.terracotta,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Card
              if (!userProvider.isLoggedIn)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkLine
                          : const Color(0xFFEBEBEB),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.forest,
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Sign In to Your Account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Access your saved properties, scheduled inspections, and profile settings.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Sign In",
                              isPrimary: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: "Register",
                              isTerracotta: true,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkLine
                            : const Color(0xFFEBEBEB),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundImage: NetworkImage(userProvider.avatarUrl),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userProvider.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkInk
                                : const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProvider.userState.isNotEmpty &&
                                  userProvider.lga.isNotEmpty
                              ? "${userProvider.lga}, ${userProvider.userState}"
                              : userProvider.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkMuted
                                : const Color(0xFF717171),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (userProvider.isLoggedIn && !userProvider.isEmailVerified) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Your email is unverified. Verify with OTP to secure your account.",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          OtpVerificationModal.show(
                            context,
                            email: userProvider.email,
                          );
                        },
                        child: const Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (userProvider.isLoggedIn && userProvider.isLandlord) ...[
                const SizedBox(height: 16),
                CustomButton(
                  text: "List a New Property",
                  isTerracotta: true,
                  icon: Icons.add_rounded,
                  width: double.infinity,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddPropertyModal(),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Settings List
              Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.settings_outlined,
                    title: "Account settings",
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: "Get help",
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("HomeHub Support & Help Center"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy & Password",
                    isDark: isDark,
                    onTap: () =>
                        _showChangePasswordModal(context, userProvider),
                  ),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: themeProvider.isDarkMode
                        ? Icons.wb_sunny_outlined
                        : Icons.dark_mode_outlined,
                    title: "Dark mode theme",
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeTrackColor: AppColors.terracotta,
                      onChanged: (v) => themeProvider.toggleTheme(),
                    ),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: Icons.menu_book_outlined,
                    title: "Legal & Terms",
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "HomeHub Terms of Service & Privacy Policy",
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  if (userProvider.isLoggedIn) ...[
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: Icons.no_accounts_outlined,
                      iconColor: Colors.red,
                      title: "Deactivate account",
                      titleColor: Colors.red,
                      isDark: isDark,
                      onTap: () =>
                          _showDeactivateAccountDialog(context, userProvider),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 28),

              // Logout Button
              if (userProvider.isLoggedIn)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      userProvider.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Signed out of account."),
                          backgroundColor: AppColors.forest,
                        ),
                      );
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- CHANGE PASSWORD MODAL ---
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
                                  ? AppColors.darkLine
                                  : AppColors.line,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.forest.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: AppColors.forest,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkInk
                                    : AppColors.ink,
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

                        Text(
                          "Current Password",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkInk : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrent,
                          decoration: _inputDecoration(
                            hint: "Enter current password",
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrent
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                              onPressed: () => setModalState(
                                () => obscureCurrent = !obscureCurrent,
                              ),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? "Current password is required"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "New Password",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkInk : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          decoration: _inputDecoration(
                            hint: "At least 6 characters",
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setModalState(() => obscureNew = !obscureNew),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "New password is required";
                            }
                            if (v.length < 4) {
                              return "Password must be at least 4 characters";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "Confirm New Password",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkInk : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirm,
                          decoration: _inputDecoration(
                            hint: "Re-enter new password",
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                              onPressed: () => setModalState(
                                () => obscureConfirm = !obscureConfirm,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v != newPasswordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        CustomButton(
                          text: isSubmitting
                              ? "Updating Password..."
                              : "Update Password",
                          width: double.infinity,
                          isPrimary: true,
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() {
                                    isSubmitting = true;
                                    errorMessage = null;
                                  });

                                  final res = await userProvider.changePassword(
                                    currentPassword:
                                        currentPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  );

                                  if (!context.mounted) return;

                                  if (res.success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res.message),
                                        backgroundColor: AppColors.forest,
                                      ),
                                    );
                                  } else {
                                    setModalState(() {
                                      isSubmitting = false;
                                      errorMessage = res.message;
                                    });
                                  }
                                },
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

  // --- DEACTIVATE ACCOUNT DIALOG ---
  void _showDeactivateAccountDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasonController = TextEditingController();
    bool isDeactivating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                                ? AppColors.darkLine
                                : AppColors.line,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Deactivate Account",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkInk : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "Are you sure you want to deactivate your account? Your profile and active property listings will be hidden, and you will be signed out.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "Reason for leaving (Optional):",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "e.g. Found a house, no longer need account",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.creamAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isDeactivating
                                  ? null
                                  : () async {
                                      setDialogState(() => isDeactivating = true);

                                      final res = await userProvider.deactivateAccount(
                                        reason: reasonController.text.trim(),
                                      );

                                      if (!context.mounted) return;

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res.message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );

                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
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

  Widget _buildSettingTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    String? subtitle,
    Widget? trailing,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? AppColors.darkInk : AppColors.forest),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? (isDark ? AppColors.darkInk : AppColors.ink),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.darkLine : AppColors.line,
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
