import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
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

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
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
        setState(() => _currentStep = 3);
      }
      return;
    }

    if (_currentStep == 3) {
      if (_formKey3.currentState!.validate()) {
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
    final success = await userProvider.register(
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

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.forest,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
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

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _stepError =
            "Registration failed. Email or phone number may already exist.";
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
            Icons.arrow_back_rounded,
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
                            Icons.home_work_rounded,
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
                              Icons.error_outline_rounded,
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
          icon: Icons.person_rounded,
          value: "user",
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        _buildRoleSelectionCard(
          title: "I'm a Landlord or Agent",
          subtitle: "Looking to list properties for rent.",
          icon: Icons.apartment_rounded,
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
              icon: Icons.person_outline_rounded,
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
              icon: Icons.person_outline_rounded,
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
              icon: Icons.mail_outline_rounded,
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
              icon: Icons.phone_outlined,
              isDark: isDark,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Please enter your phone number";
              }
              if (v.trim().length < 10) {
                return "Enter a valid 11-digit phone number";
              }
              return null;
            },
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
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
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
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
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
                Icons.check_circle_rounded,
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
