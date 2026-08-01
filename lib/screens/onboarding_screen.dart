import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "tag": "ZERO AGENCY MARKUPS",
      "title": "Rentals Worth\nMoving In For.",
      "description": "Verified flats, duplexes, and student housing across Ekiti State straight from verified landlords. No ghost listings.",
      "image": "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80",
    },
    {
      "tag": "EASY INSPECTIONS",
      "title": "In-Person &\n3D Virtual Tours.",
      "description": "Schedule physical viewing slots or explore immersive 3D virtual tours before making any rent commitment.",
      "image": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
    },
    {
      "tag": "ESCROW PROTECTION",
      "title": "Digital E-Sign &\nPayment Protection.",
      "description": "Sign tenancy contracts electronically in-app and pay rent via HomeHub Escrow. Funds are released only after move-in.",
      "image": "https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Logo & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "HomeHub",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkInk : AppColors.forest,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox(
                            height: 260,
                            width: double.infinity,
                            child: Image.network(
                              slide["image"]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            slide["tag"]!,
                            style: const TextStyle(
                              color: AppColors.terracotta,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Title
                        Text(
                          slide["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            color: isDark ? AppColors.darkInk : AppColors.forest,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          slide["description"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.45,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area (Indicators + Next/Get Started Button)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == idx ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx ? AppColors.terracotta : (isDark ? AppColors.darkLine : AppColors.line),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Button
                  CustomButton(
                    text: _currentPage == _slides.length - 1 ? "Get Started" : "Continue",
                    isTerracotta: true,
                    width: double.infinity,
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
