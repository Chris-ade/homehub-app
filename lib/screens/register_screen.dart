import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_verification_modal.dart';
import 'main_navigation_screen.dart';
import 'login_screen.dart';

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
            () =>
                _stepError =
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
              () =>
                  _stepError =
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
            () =>
                _stepError =
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
            setState(
              () =>
                  _stepError =
                      _phoneCheckMessage ??
                      "This phone number is already registered.",
            );
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
          setState(
            () =>
                _stepError = "Please accept the Terms of Service to continue.",
          );
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
      Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.forest,
          content: Row(
            children: [
              const Icon(LucideIcons.circle_check, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Account created! Welcome to HomeHub, ${_firstNameController.text.trim()}.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Offer OTP verification modal
      final userEmail = _emailController.text.trim();
      await OtpVerificationModal.show(
        context,
        email: userEmail,
        onVerified: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email verified! Welcome aboard."),
              backgroundColor: AppColors.forest,
            ),
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _stepError = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _currentStep == 0 ? 0.1 : (_currentStep / _totalSteps);

    return Scaffold(
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
            fontSize: 14,
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
                    // Header Logo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.building_2,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "HomeHub",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkInk
                                : AppColors.forest,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (_stepError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.circle_alert,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _stepError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

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
                    ),

                    const SizedBox(height: 20),

                    // Switch to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.muted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 13,
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
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkInk : AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Select how you intend to use HomeHub.",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ),
        const SizedBox(height: 24),

        _buildRoleSelectionCard(
          title: "I'm a Tenant / House Seeker",
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
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Enter your official full name as it appears on your ID.",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "First Name",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _firstNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: "e.g. Tunde",
              icon: LucideIcons.user,
              isDark: isDark,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? "Please enter your first name"
                : null,
          ),

          const SizedBox(height: 18),

          Text(
            "Last Name",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: "e.g. Aluko",
              icon: LucideIcons.user,
              isDark: isDark,
            ),
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
    Widget? emailSuffix;
    if (_isCheckingEmail) {
      emailSuffix = const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.terracotta,
          ),
        ),
      );
    } else if (_isEmailAvailable == true) {
      emailSuffix = const Icon(
        LucideIcons.circle_check,
        color: Colors.green,
        size: 20,
      );
    } else if (_isEmailAvailable == false) {
      emailSuffix = const Icon(
        LucideIcons.circle_alert,
        color: Colors.red,
        size: 20,
      );
    }

    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter your email address",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "We will send digital lease updates & inspection notices to this email.",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Email Address",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: "name@example.com",
              icon: LucideIcons.mail,
              isDark: isDark,
              suffixIcon: emailSuffix,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Please enter your email address";
              }
              if (!v.contains("@") || !v.contains(".")) {
                return "Enter a valid email address";
              }
              if (_isEmailAvailable == false) {
                return _emailCheckMessage ??
                    "This email address is already registered";
              }
              return null;
            },
          ),

          if (_isCheckingEmail || _isEmailAvailable != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (_isCheckingEmail) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Checking email availability...",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                ] else if (_isEmailAvailable == true) ...[
                  const Icon(
                    LucideIcons.circle_check,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _emailCheckMessage ?? "Email address is available",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (_isEmailAvailable == false) ...[
                  const Icon(
                    LucideIcons.circle_alert,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _emailCheckMessage ??
                          "This email address is already registered",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // STEP 3: Phone
  Widget _buildStepPhone(bool isDark) {
    Widget? phoneSuffix;
    if (_isCheckingPhone) {
      phoneSuffix = const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.terracotta,
          ),
        ),
      );
    } else if (_isPhoneAvailable == true) {
      phoneSuffix = const Icon(
        LucideIcons.circle_check,
        color: Colors.green,
        size: 20,
      );
    } else if (_isPhoneAvailable == false) {
      phoneSuffix = const Icon(
        LucideIcons.circle_alert,
        color: Colors.red,
        size: 20,
      );
    }

    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your mobile number",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Used for instant SMS inspection reminders and landlord calls.",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Mobile Phone Number",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hint: "+234 801 234 5678",
              icon: LucideIcons.phone,
              isDark: isDark,
              suffixIcon: phoneSuffix,
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

          if (_isCheckingPhone || _isPhoneAvailable != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (_isCheckingPhone) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Checking phone number availability...",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                ] else if (_isPhoneAvailable == true) ...[
                  const Icon(
                    LucideIcons.circle_check,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _phoneCheckMessage ?? "Phone number is available",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (_isPhoneAvailable == false) ...[
                  const Icon(
                    LucideIcons.circle_alert,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _phoneCheckMessage ??
                          "This phone number is already registered",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
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
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkInk : AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Choose a strong password to secure your tenancy account.",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Password",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration(
              hint: "At least 6 characters",
              icon: LucideIcons.lock,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? LucideIcons.eye_off
                      : LucideIcons.eye,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Password is required";
              if (v.length < 4) return "Must be at least 4 characters";
              return null;
            },
          ),

          const SizedBox(height: 18),

          Text(
            "Confirm Password",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkInk : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: _inputDecoration(
              hint: "Re-enter password",
              icon: LucideIcons.lock,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? LucideIcons.eye_off
                      : LucideIcons.eye,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ),
            validator: (v) {
              if (v != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Terms Checkbox
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                activeColor: AppColors.terracotta,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              ),
              Expanded(
                child: Text(
                  "I agree to the HomeHub Terms of Service & Privacy Policy.",
                  style: TextStyle(
                    fontSize: 12,
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
                      fontSize: 15,
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
                      fontSize: 12,
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
      prefixIcon: Icon(icon, color: AppColors.forest, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
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
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
      ),
    );
  }
}
