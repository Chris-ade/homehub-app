import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../theme/app_theme.dart';

class NoDataWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? cityName;
  final bool notify;

  const NoDataWidget({
    super.key,
    this.icon = LucideIcons.house,
    required this.title,
    required this.message,
    this.cityName,
    this.notify = false,
  });

  void _onNotifyMe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "We'll notify you the moment $cityName has new properties!",
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.15)
                  : AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: isDark ? AppColors.white : AppColors.accent),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          if (notify)
            ElevatedButton.icon(
              onPressed: () => _onNotifyMe(context),
              icon: const Icon(LucideIcons.bell, size: 18),
              label: const Text(
                "Notify Me",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
