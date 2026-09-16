import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/inputs/form_input_field.dart';
import '../../widgets/app_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _emailSent = false;
  String? _sentEmail;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? "");
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final result = await userProvider.requestPasswordReset(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      setState(() {
        _emailSent = true;
        _sentEmail = email;
      });
      AppToast.showSuccess(
        context,
        message: result.message.isNotEmpty
            ? result.message
            : "Password reset link sent to your email.",
      );
    } else {
      AppToast.showError(
        context,
        message: result.message.isNotEmpty
            ? result.message
            : "Failed to request password reset. Please try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrow_left,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: _emailSent
              ? _buildSuccessState(isDark)
              : _buildFormState(isDark),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Key Icon Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccent : AppColors.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              LucideIcons.key_round,
              size: 28,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Heading
          Text(
            "Forgot password?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cabinet Grotesk',
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            "No worries, it happens. Enter the email associated with your account and we'll send you a password reset link.",
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Email Input
          FormInputField(
            label: "E-mail address",
            controller: _emailController,
            hintText: "you@example.com",
            isDark: isDark,
            prefixIcon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Email is required";
              }
              if (!v.contains("@") || !v.contains(".")) {
                return "Enter a valid email address";
              }
              return null;
            },
          ),

          const SizedBox(height: 28),

          // Submit Button
          CustomButton(
            text: _isLoading ? "Sending..." : "Send Reset Link",
            width: double.infinity,
            onPressed: _isLoading ? null : _handleResetPassword,
          ),

          const SizedBox(height: 28),

          // Back to login button
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.arrow_left,
                    size: 16,
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Back to Login",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),

        // Success Icon Badge
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.mail_check,
            size: 48,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 28),

        // Heading
        Text(
          "Check your email",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cabinet Grotesk',
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "We have sent password reset instructions to:\n${_sentEmail ?? ''}",
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 36),

        // Back to Login Button
        CustomButton(
          text: "Back to Login",
          width: double.infinity,
          onPressed: () => Navigator.pop(context),
        ),

        const SizedBox(height: 20),

        // Resend Link Option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the email? ",
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                      setState(() => _emailSent = false);
                      _handleResetPassword();
                    },
              child: Text(
                "Click to resend",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkAccent : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
