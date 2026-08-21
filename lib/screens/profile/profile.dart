import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/app_theme_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/modals/otp_verification.dart';
import '../../widgets/app_toast.dart';
import 'edit.dart';
import '../auth/login.dart';
import '../auth/register.dart';

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
              LucideIcons.bell,
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
        color: AppColors.amber,
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
                        backgroundColor: AppColors.teal,
                        child: Icon(
                          LucideIcons.user,
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
                              isAmber: true,
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
                        LucideIcons.triangle_alert,
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
                          backgroundColor: AppColors.amber,
                          foregroundColor: AppColors.ink,
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

              const SizedBox(height: 24),

              // Settings List
              Column(
                children: [
                  _buildSettingTile(
                    icon: LucideIcons.settings,
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
                    icon: LucideIcons.life_buoy,
                    title: "Get help",
                    isDark: isDark,
                    onTap: () {
                      AppToast.showInfo(
                        context,
                        message: "HomeHub Support & Help Center",
                        actionLabel: "Contact",
                        onAction: () {},
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: LucideIcons.sparkles,
                    title: "Toast Component Demo",
                    isDark: isDark,
                    onTap: () => _showToastShowcaseModal(context),
                  ),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: LucideIcons.shield,
                    title: "Privacy & Password",
                    isDark: isDark,
                    onTap: () =>
                        _showChangePasswordModal(context, userProvider),
                  ),
                  _buildDivider(isDark),

                  _buildThemeModeTile(themeProvider, isDark),
                  _buildDivider(isDark),

                  _buildSettingTile(
                    icon: LucideIcons.book_open,
                    title: "Legal & Terms",
                    isDark: isDark,
                    onTap: () {
                      AppToast.show(
                        context,
                        message: "HomeHub Terms of Service & Privacy Policy",
                        actionLabel: "View",
                        onAction: () {},
                      );
                    },
                  ),

                  if (userProvider.isLoggedIn) ...[
                    _buildDivider(isDark),
                    _buildSettingTile(
                      icon: LucideIcons.user_x,
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
                      context.read<PropertyProvider>().clearFavorites();
                      AppToast.showInfo(context, message: "Signed out of account.");
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      LucideIcons.log_out,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
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

  // --- TOAST SHOWCASE MODAL ---
  void _showToastShowcaseModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.sparkles,
                      color: isDark ? AppColors.darkAccent : AppColors.amberDeep,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Toast Showcase",
                    style: TextStyle(
                      fontFamily: 'Cabinet Grotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkInk : AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Tap any toast style below to test the animated, swipeable toast overlay.",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons grid/list
              _buildDemoButton(
                context,
                label: "Success Toast",
                icon: LucideIcons.circle_check,
                color: AppColors.success,
                onTap: () {
                  AppToast.showSuccess(
                    context,
                    message: "Listing saved to your Bookmarks",
                    actionLabel: "Undo",
                    onAction: () {},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildDemoButton(
                context,
                label: "Error Toast",
                icon: LucideIcons.circle_alert,
                color: AppColors.error,
                onTap: () {
                  AppToast.showError(
                    context,
                    message: "Unable to sync updates with server",
                    actionLabel: "Retry",
                    onAction: () {},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildDemoButton(
                context,
                label: "Info Toast",
                icon: LucideIcons.info,
                color: AppColors.info,
                onTap: () {
                  AppToast.showInfo(
                    context,
                    message: "New verified homes available in Ado-Ekiti!",
                    actionLabel: "Explore",
                    onAction: () {},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildDemoButton(
                context,
                label: "Warning Toast",
                icon: LucideIcons.triangle_alert,
                color: AppColors.warning,
                onTap: () {
                  AppToast.showWarning(
                    context,
                    message: "Your host verification is pending approval",
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildDemoButton(
                context,
                label: "Top Position Banner Toast",
                icon: LucideIcons.arrow_up,
                color: AppColors.teal,
                onTap: () {
                  AppToast.show(
                    context,
                    message: "Notification preferences updated",
                    position: ToastPosition.top,
                    type: ToastType.success,
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildDemoButton(
                context,
                label: "Avatar Notification Toast",
                icon: LucideIcons.user,
                color: Colors.purple,
                onTap: () {
                  AppToast.show(
                    context,
                    message: "Agent Alex sent you a new message",
                    avatarUrl:
                        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
                    actionLabel: "View",
                    onAction: () {},
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemoButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.offWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkLine : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkInk : AppColors.ink,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevron_right,
              size: 16,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ],
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
                                color: AppColors.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.lock,
                                color: AppColors.teal,
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
                            icon: LucideIcons.lock,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrent
                                    ? LucideIcons.eye_off
                                    : LucideIcons.eye,
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
                            icon: LucideIcons.lock,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew
                                    ? LucideIcons.eye_off
                                    : LucideIcons.eye,
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
                            icon: LucideIcons.lock,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? LucideIcons.eye_off
                                    : LucideIcons.eye,
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
                                        backgroundColor: AppColors.teal,
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
                            color: isDark ? AppColors.darkLine : AppColors.line,
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
                              LucideIcons.triangle_alert,
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
                          hintText:
                              "e.g. Found a house, no longer need account",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.muted,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.mist,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
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
                                  vertical: 14,
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
        color: iconColor ?? (isDark ? AppColors.darkInk : AppColors.teal),
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
            LucideIcons.chevron_right,
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

  /// Appearance row with a System / Light / Dark segmented control. "System"
  /// follows the device; the choice persists via AppThemeProvider.
  Widget _buildThemeModeTile(AppThemeProvider themeProvider, bool isDark) {
    final accent = isDark ? AppColors.darkAccent : AppColors.amber;

    Widget segment(ThemeMode mode, IconData icon, String label) {
      final selected = themeProvider.themeMode == mode;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => themeProvider.setThemeMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : (isDark ? AppColors.darkMuted : AppColors.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : (isDark ? AppColors.darkMuted : AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                themeProvider.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                size: 20,
                color: isDark ? AppColors.darkInk : AppColors.teal,
              ),
              const SizedBox(width: 16),
              Text(
                "Appearance",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkInk : AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.mist,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                segment(ThemeMode.system, LucideIcons.smartphone, "System"),
                segment(ThemeMode.light, LucideIcons.sun, "Light"),
                segment(ThemeMode.dark, LucideIcons.moon, "Dark"),
              ],
            ),
          ),
        ],
      ),
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
      prefixIcon: Icon(icon, color: AppColors.teal, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.mist,
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
        borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
      ),
    );
  }
}
