import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../theme/app_theme.dart';

class NoDataWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String cityName;

  const NoDataWidget({
    super.key,
    this.icon = LucideIcons.house,
    required this.title,
    required this.message,
    required this.cityName,
  });

  void _onNotifyMe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("We'll notify you the moment $cityName has new properties!"),
        backgroundColor: AppColors.forest,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.terracotta.withValues(alpha: 0.15)
                  : AppColors.creamAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: AppColors.terracotta,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkInk : AppColors.forest,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),

          const SizedBox(height: 20),

          // Clean "Notify Me" Button without text field
          ElevatedButton.icon(
            onPressed: () => _onNotifyMe(context),
            icon: const Icon(LucideIcons.bell, size: 18),
            label: const Text(
              "Notify Me",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
