import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/inputs/form_input_field.dart';
import '../../widgets/inputs/custom_input_field.dart';
import '../../widgets/app_toast.dart';
import '../navbar.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final result = await userProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      // Load this user's saved properties (fire-and-forget; won't block nav).
      context.read<PropertyProvider>().fetchBookmarksFromApi();

      AppToast.showSuccess(
        context,
        message: "Welcome back, ${userProvider.name}!",
      );

      // Navigate to main navigation screen & clear auth stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      final errorMsg = result.message.isNotEmpty
          ? result.message
          : "Invalid email or password. Please try again.";
      AppToast.showError(context, message: errorMsg);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    bool isSubmittingReset = false;
    String? resetStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              title: Row(
                children: [
                  const Icon(
                    LucideIcons.key_round,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your email address and we'll send you a password reset link.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    controller: resetEmailController,
                    hintText: "you@example.com",
                    isDark: isDark,
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (resetStatus != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      resetStatus!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkAccent : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSubmittingReset
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) return;

                          setDialogState(() {
                            isSubmittingReset = true;
                          });

                          final userProvider = context.read<UserProvider>();
                          final res = await userProvider.requestPasswordReset(
                            email,
                          );

                          setDialogState(() {
                            isSubmittingReset = false;
                            resetStatus = res.message;
                          });
                        },
                  child: Text(
                    isSubmittingReset ? "Sending..." : "Send Request",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Logo & Header Branding
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.building_2,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "HomeHub",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Already have an account? Enter your details to continue.",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Email Address Input
                  FormInputField(
                    label: "E-mail address",
                    controller: _emailController,
                    hintText: "you@example.com",
                    isDark: isDark,
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Email is required";
                      }
                      if (!v.contains("@")) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Password Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Password",
                        style: TextStyle(
                          fontSize: AppFontSizes.labelLarge,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: AppFontSizes.labelMedium,
                            color: isDark ? AppColors.darkAccent : AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CustomInputField(
                    controller: _passwordController,
                    hintText: "••••••••",
                    isDark: isDark,
                    prefixIcon: LucideIcons.lock,
                    obscureText: _obscurePassword,
                    customSuffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? LucideIcons.eye_off
                            : LucideIcons.eye,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Password is required";
                      }
                      if (v.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Submit Button
                  CustomButton(
                    text: _isLoading ? "Signing In..." : "Sign in",
                    width: double.infinity,
                    onPressed: _isLoading ? null : _handleLogin,
                  ),

                  const SizedBox(height: 24),

                  // Switch to Register Screen Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 17,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Create one",
                          style: TextStyle(
                            fontSize: 17,
                            color: isDark ? AppColors.darkAccent : AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
