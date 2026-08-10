import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/modals/otp_verification.dart';
import '../../widgets/inputs/form_input_field.dart';
import '../../widgets/inputs/validation_status_message.dart';
import '../../widgets/app_toast.dart';
import '../navbar.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Step tracker:
  // 0: Role Selection (Tenant vs Landlord)
  // 1: Personal Info (First Name, Last Name)
  // 2: Email Address
  // 3: Phone Number
  // 4: Security & Password
  int _currentStep = 0;
  final int _totalSteps = 4;

  String _role = "user"; // "user" = Tenant, "agent" = Landlord / Agent
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _stepError;

  // Real-time email and phone verification state
  bool _isCheckingEmail = false;
  bool? _isEmailAvailable;
  String? _emailCheckMessage;
  Timer? _emailDebounce;

  bool _isCheckingPhone = false;
  bool? _isPhoneAvailable;
  String? _phoneCheckMessage;
  Timer? _phoneDebounce;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _phoneDebounce?.cancel();
    _emailController.removeListener(_onEmailChanged);
    _phoneController.removeListener(_onPhoneChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    if (text.isEmpty || !text.contains('@') || !text.contains('.')) {
      if (_isEmailAvailable != null || _emailCheckMessage != null) {
        setState(() {
          _isEmailAvailable = null;
          _emailCheckMessage = null;
          _isCheckingEmail = false;
        });
      }
      return;
    }

    _emailDebounce?.cancel();
    _emailDebounce = Timer(const Duration(milliseconds: 500), () {
      _verifyEmailAvailability();
    });
  }

  Future<void> _verifyEmailAvailability() async {
    final text = _emailController.text.trim();
    if (text.isEmpty || !text.contains('@') || !text.contains('.')) return;

    setState(() {
      _isCheckingEmail = true;
      _emailCheckMessage = null;
    });

    final userProvider = context.read<UserProvider>();
    final res = await userProvider.checkEmailAvailability(text);

    if (!mounted) return;

    setState(() {
      _isCheckingEmail = false;
      _isEmailAvailable = res.available;
      _emailCheckMessage = res.message;
    });
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    if (text.isEmpty || text.length < 10) {
      if (_isPhoneAvailable != null || _phoneCheckMessage != null) {
        setState(() {
          _isPhoneAvailable = null;
          _phoneCheckMessage = null;
          _isCheckingPhone = false;
        });
      }
      return;
    }

    _phoneDebounce?.cancel();
    _phoneDebounce = Timer(const Duration(milliseconds: 500), () {
      _verifyPhoneAvailability();
    });
  }

  Future<void> _verifyPhoneAvailability() async {
    final text = _phoneController.text.trim();
    if (text.isEmpty || text.length < 10) return;

    setState(() {
      _isCheckingPhone = true;
      _phoneCheckMessage = null;
    });

    final userProvider = context.read<UserProvider>();
    final res = await userProvider.checkPhoneAvailability(text);

    if (!mounted) return;

    setState(() {
      _isCheckingPhone = false;
      _isPhoneAvailable = res.available;
      _phoneCheckMessage = res.message;
    });
  }

  Future<void> _nextStep() async {
    setState(() => _stepError = null);

    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
      return;
    }

    if (_currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep = 2);
      }
      return;
    }

    if (_currentStep == 2) {
      if (_formKey2.currentState!.validate()) {
        if (_isEmailAvailable == false) {
          setState(
            () => _stepError =
                _emailCheckMessage ??
                "This email address is already registered.",
          );
          return;
        }
        if (_isEmailAvailable == null) {
          setState(() => _isLoading = true);
          await _verifyEmailAvailability();
          if (!mounted) return;
          setState(() => _isLoading = false);
          if (_isEmailAvailable == false) {
            setState(
              () => _stepError =
                  _emailCheckMessage ??
                  "This email address is already registered.",
            );
            return;
          }
        }
        setState(() => _currentStep = 3);
      }
      return;
    }

    if (_currentStep == 3) {
      if (_formKey3.currentState!.validate()) {
        if (_isPhoneAvailable == false) {
          setState(
            () => _stepError =
                _phoneCheckMessage ??
                "This phone number is already registered.",
          );
          return;
        }
        if (_isPhoneAvailable == null) {
          setState(() => _isLoading = true);
          await _verifyPhoneAvailability();
          if (!mounted) return;
          setState(() => _isLoading = false);
          if (_isPhoneAvailable == false) {
            final errorMsg = _phoneCheckMessage ?? "This phone number is already registered.";
            setState(() => _stepError = errorMsg);
            AppToast.showError(context, message: errorMsg);
            return;
          }
        }
        setState(() => _currentStep = 4);
      }
      return;
    }

    if (_currentStep == 4) {
      if (_formKey4.currentState!.validate()) {
        if (!_agreedToTerms) {
          const errorMsg = "Please accept the Terms of Service to continue.";
          setState(() => _stepError = errorMsg);
          AppToast.showWarning(context, message: errorMsg);
          return;
        }
        _handleFinalRegister();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _stepError = null;
        _currentStep--;
      });
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _handleFinalRegister() async {
    setState(() {
      _isLoading = true;
      _stepError = null;
    });

    final userProvider = context.read<UserProvider>();
    final result = await userProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: _role,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      AppToast.showSuccess(
        context,
        message: "Account created! Welcome to HomeHub, ${_firstNameController.text.trim()}.",
      );

      // Offer OTP verification modal
      final userEmail = _emailController.text.trim();
      await OtpVerificationModal.show(
        context,
        email: userEmail,
        onVerified: () {
          AppToast.showSuccess(
            context,
            message: "Email verified! Welcome aboard.",
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      final errorMsg = result.message.isNotEmpty
          ? result.message
          : "Registration failed. Please try again.";
      setState(() {
        _stepError = errorMsg;
      });
      AppToast.showError(
        context,
        message: errorMsg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _currentStep == 0 ? 0.1 : (_currentStep / _totalSteps);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _previousStep();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrow_left,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
            onPressed: _previousStep,
          ),
          title: Text(
            "Step ${_currentStep == 0 ? "1" : _currentStep} of $_totalSteps",
            style: TextStyle(
              fontSize: AppFontSizes.titleMedium,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Animated Step Progress Line Bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.creamAlt,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.terracotta,
                ),
                minHeight: 4,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // STEP CONTENT BUILDER
                      _buildStepView(isDark),

                      const SizedBox(height: 30),

                      // Next / Submit Button
                      CustomButton(
                        text: _isLoading
                            ? "Creating Account..."
                            : (_currentStep == 4 ? "Create account" : "Next"),
                        width: double.infinity,
                        onPressed: _isLoading ? null : _nextStep,
                        isDisabled: _isLoading || _stepError != null,
                      ),

                      const SizedBox(height: 20),

                      // Switch to Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 17,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColors.terracotta,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepView(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStepRole(isDark);
      case 1:
        return _buildStepPersonalInfo(isDark);
      case 2:
        return _buildStepEmail(isDark);
      case 3:
        return _buildStepPhone(isDark);
      case 4:
        return _buildStepSecurity(isDark);
      default:
        return _buildStepRole(isDark);
    }
  }

  // STEP 0: Account Role
  Widget _buildStepRole(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sign up as",
          style: TextStyle(
            fontSize: AppFontSizes.displaySmall,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkInk : AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Select how you intend to use HomeHub.",
          style: TextStyle(
            fontSize: AppFontSizes.bodyLarge,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ),
        const SizedBox(height: 24),

        _buildRoleSelectionCard(
          title: "I'm a Tenant",
          subtitle: "Looking for housing.",
          icon: LucideIcons.user,
          value: "user",
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        _buildRoleSelectionCard(
          title: "I'm a Landlord or Agent",
          subtitle: "Looking to list properties for rent.",
          icon: LucideIcons.building_2,
          value: "agent",
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 1: Personal Info
  Widget _buildStepPersonalInfo(bool isDark) {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your name?",
            style: TextStyle(
              fontSize: AppFontSizes.displaySmall,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Enter your full name.",
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          FormInputField(
            label: "First Name",
            controller: _firstNameController,
            hintText: "e.g. Tunde",
            isDark: isDark,
            prefixIcon: LucideIcons.user,
            textCapitalization: TextCapitalization.words,
            validator: (v) => v == null || v.trim().isEmpty
                ? "Please enter your first name"
                : null,
          ),

          const SizedBox(height: 18),

          FormInputField(
            label: "Last Name / Surname",
            controller: _lastNameController,
            hintText: "e.g. Aluko",
            isDark: isDark,
            prefixIcon: LucideIcons.user,
            textCapitalization: TextCapitalization.words,
            validator: (v) => v == null || v.trim().isEmpty
                ? "Please enter your last name"
                : null,
          ),
        ],
      ),
    );
  }

  // STEP 2: Email
  Widget _buildStepEmail(bool isDark) {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter your email address",
            style: TextStyle(
              fontSize: AppFontSizes.displaySmall,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "We need your email address to verify your account.",
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),

          FormInputField(
            label: "",
            controller: _emailController,
            hintText: "name@example.com",
            isDark: isDark,
            prefixIcon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            customSuffixIcon: ValidationStatusMessage.buildSuffixIcon(
              isChecking: _isCheckingEmail,
              isAvailable: _isEmailAvailable,
              isDark: isDark,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Please enter your email address";
              }
              if (!v.contains("@") || !v.contains(".")) {
                return "Enter a valid email address";
              }
              return null;
            },
          ),

          ValidationStatusMessage(
            isChecking: _isCheckingEmail,
            isAvailable: _isEmailAvailable,
            isDark: isDark,
            loadingText: "Checking email availability...",
            availableText: "E-mail address is available",
            unavailableText: "This email address is already registered",
            customMessage: _emailCheckMessage,
          ),
        ],
      ),
    );
  }

  // STEP 3: Phone
  Widget _buildStepPhone(bool isDark) {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your mobile number",
            style: TextStyle(
              fontSize: AppFontSizes.displaySmall,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "We also need your mobile number to verify your account.",
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),

          FormInputField(
            label: "",
            controller: _phoneController,
            hintText: "08012345678",
            isDark: isDark,
            prefixIcon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            customSuffixIcon: ValidationStatusMessage.buildSuffixIcon(
              isChecking: _isCheckingPhone,
              isAvailable: _isPhoneAvailable,
              isDark: isDark,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Please enter your phone number";
              }
              if (v.trim().length < 10) {
                return "Enter a valid 11-digit phone number";
              }
              if (_isPhoneAvailable == false) {
                return _phoneCheckMessage ??
                    "This phone number is already registered";
              }
              return null;
            },
          ),

          ValidationStatusMessage(
            isChecking: _isCheckingPhone,
            isAvailable: _isPhoneAvailable,
            isDark: isDark,
            loadingText: "Checking phone number availability...",
            availableText: "Phone number is available",
            unavailableText: "This phone number is already registered",
            customMessage: _phoneCheckMessage,
          ),
        ],
      ),
    );
  }

  // STEP 4: Password Security & Agreement
  Widget _buildStepSecurity(bool isDark) {
    return Form(
      key: _formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create a password",
            style: TextStyle(
              fontSize: AppFontSizes.displaySmall,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Choose a strong password to secure your account.",
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          FormInputField(
            label: "Password",
            controller: _passwordController,
            hintText: "At least 6 characters",
            isDark: isDark,
            prefixIcon: LucideIcons.lock,
            obscureText: _obscurePassword,
            customSuffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eye_off : LucideIcons.eye,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Password is required";
              if (v.length < 4) return "Must be at least 4 characters";
              return null;
            },
          ),

          const SizedBox(height: 18),

          FormInputField(
            label: "Confirm Password",
            controller: _confirmPasswordController,
            hintText: "Re-enter password",
            isDark: isDark,
            prefixIcon: LucideIcons.lock,
            obscureText: _obscureConfirmPassword,
            customSuffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? LucideIcons.eye_off : LucideIcons.eye,
                size: 20,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
            validator: (v) {
              if (v != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Terms Checkbox
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                activeColor: isDark ? AppColors.terracotta : AppColors.forest,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              ),
              Expanded(
                child: Text(
                  "I agree to the Terms of Service & Privacy Policy.",
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.terracotta.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.terracotta
                : (isDark ? AppColors.darkLine : AppColors.line),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.terracotta
                    : (isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkInk : AppColors.forest),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.terracotta
                          : (isDark ? AppColors.darkInk : AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodyMedium,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                LucideIcons.circle_check,
                color: AppColors.terracotta,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
