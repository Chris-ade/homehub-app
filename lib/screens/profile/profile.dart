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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          "Your profile",
          style: TextStyle(
            fontSize: AppFontSizes.titleLarge,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (userProvider.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: "Edit profile",
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.user_pen,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.fetchMe();
        },
        color: isDark ? AppColors.white : AppColors.primary,
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
                          ? AppColors.darkBorder
                          : const Color(0xFFEBEBEB),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
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
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Access your saved properties, scheduled inspections, and profile settings.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
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
                            ? AppColors.darkBorder
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
                                ? AppColors.darkTextPrimary
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
                                ? AppColors.darkTextSecondary
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
                          backgroundColor: isDark
                              ? AppColors.white
                              : AppColors.primary,
                          foregroundColor: isDark
                              ? AppColors.textPrimary
                              : Colors.white,
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
                    subtitle: "Personal info, password & account",
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
                      AppToast.showInfo(
                        context,
                        message: "Signed out of account.",
                      );
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
        color:
            iconColor ??
            (isDark ? AppColors.darkTextPrimary : AppColors.primary),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color:
              titleColor ??
              (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            LucideIcons.chevron_right,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }

  /// Appearance row with a System / Light / Dark segmented control. "System"
  /// follows the device; the choice persists via AppThemeProvider.
  Widget _buildThemeModeTile(AppThemeProvider themeProvider, bool isDark) {
    final accent = isDark ? AppColors.darkAccent : AppColors.primary;

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
                      ? (isDark
                            ? AppColors.textPrimary
                            : AppColors.darkTextPrimary)
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? (isDark
                              ? AppColors.textPrimary
                              : AppColors.darkTextPrimary)
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
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
                color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
              ),
              const SizedBox(width: 16),
              Text(
                "Appearance",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
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
}
