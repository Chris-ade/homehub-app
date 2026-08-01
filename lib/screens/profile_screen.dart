import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/app_theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_property_modal.dart';
import '../widgets/custom_button.dart';

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
          "Account & Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Info Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(userProvider.avatarUrl),
                          ),
                          if (userProvider.isVerified)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.forest,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkInk : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userProvider.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: userProvider.isLandlord
                                    ? AppColors.terracotta.withValues(alpha: 0.15)
                                    : AppColors.forest.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                userProvider.isLandlord ? "Landlord / Agent Mode" : "Tenant Mode",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: userProvider.isLandlord ? AppColors.terracotta : AppColors.forest,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: isDark ? AppColors.darkLine : AppColors.line),
                  const SizedBox(height: 12),

                  // Mode Toggle Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Switch to Landlord Mode",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkInk : AppColors.ink,
                            ),
                          ),
                          Text(
                            "List properties & manage tenants",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: userProvider.isLandlord,
                        activeTrackColor: AppColors.terracotta,
                        onChanged: (val) => userProvider.toggleRole(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Landlord Quick Action Button
            if (userProvider.isLandlord)
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

            const SizedBox(height: 20),

            // Settings Options List
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    title: "Dark Mode Theme",
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeTrackColor: AppColors.terracotta,
                      onChanged: (v) => themeProvider.toggleTheme(),
                    ),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingTile(
                    icon: Icons.verified_user_rounded,
                    title: "Identity Verification (NIN / BVN)",
                    subtitle: "Verified (Level 2 Active)",
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingTile(
                    icon: Icons.credit_card_rounded,
                    title: "Escrow Payment Methods",
                    subtitle: "Debit Cards, Bank Transfer, Paystack",
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help & Support",
                    subtitle: "24/7 Support line & FAQs",
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingTile(
                    icon: Icons.description_rounded,
                    title: "Terms & Privacy Policy",
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? AppColors.darkInk : AppColors.forest, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkInk : AppColors.ink,
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
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? AppColors.darkMuted : AppColors.muted),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 56, color: isDark ? AppColors.darkLine : AppColors.line);
  }
}
