import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'home.dart';
import 'search.dart';
import 'saved.dart';
import 'messages/messages.dart';
import 'profile/profile.dart';
import 'auth/login.dart';
import 'landlord/dashboard.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // Strict Auth Guard: Unauthenticated users MUST NOT see tabs or main app.
    if (!userProvider.isLoggedIn) {
      return const LoginScreen();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      // Landlords land directly on their dashboard as the primary screen;
      // tenants get the public browse home. Either way the tab stays at index 0.
      if (userProvider.isLandlord)
        const LandlordDashboardScreen()
      else
        HomeScreen(onNavigateTab: _onTabSelected),
      const SearchScreen(),
      const FavoritesScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.line,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.teal.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark ? AppColors.darkAccent : AppColors.amberDeep,
          unselectedItemColor: isDark ? AppColors.darkMuted : AppColors.muted,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                userProvider.isLandlord
                    ? LucideIcons.layout_dashboard
                    : LucideIcons.house,
              ),
              activeIcon: Icon(
                userProvider.isLandlord
                    ? LucideIcons.layout_dashboard
                    : LucideIcons.house,
                color: isDark ? AppColors.darkAccent : AppColors.amberDeep,
              ),
              label: userProvider.isLandlord ? "Dashboard" : "Home",
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.search),
              activeIcon: Icon(LucideIcons.search, color: isDark ? AppColors.darkAccent : AppColors.amberDeep),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.heart),
              activeIcon: Icon(LucideIcons.heart, color: isDark ? AppColors.darkAccent : AppColors.amberDeep),
              label: "Saved",
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.mail),
              activeIcon: Icon(LucideIcons.mail, color: isDark ? AppColors.darkAccent : AppColors.amberDeep),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.user),
              activeIcon: Icon(LucideIcons.user, color: isDark ? AppColors.darkAccent : AppColors.amberDeep),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
