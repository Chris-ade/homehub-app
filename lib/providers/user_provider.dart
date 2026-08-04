import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../models/user_model.dart';
import '../config/app_config.dart';
import '../services/api_client.dart';

enum UserRole { tenant, landlord }

class AuthResponse {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? userData;

  AuthResponse({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.userData,
  });
}

class UserProvider extends ChangeNotifier implements AuthTokenProvider {
  final ApiClient _api;

  bool _isLoggedIn = false;
  bool _isInitializing = true;
  bool _hasCompletedOnboarding = false;
  String _id = "";
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _phone = "";
  String _avatarUrl =
      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80";
  bool _isVerified = false;
  bool _isEmailVerified = false;
  UserRole _role = UserRole.tenant;
  double _profileCompletionPercentage = 0.85;
  String? _accessToken;
  String? _refreshToken;

  UserModel? _userModel;
  LandlordProfile? _landlordProfile;
  TenantProfile? _tenantProfile;

  // Base API URL (single source of truth in AppConfig)
  static const String baseUrl = AppConfig.apiBaseUrl;

  UserProvider(this._api) {
    _api.authProvider = this;
    initAuth();
  }

  String _state = "Lagos";
  String _lga = "Ikeja";
  String _address = "";
  String _gender = "Male";
  String _bio = "";

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String get id => _id;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get name {
    final full = "$_firstName $_lastName".trim();
    if (full.isNotEmpty) return full;
    if (_email.isNotEmpty) return _email.split('@').first.toUpperCase();
    return "HomeHub User";
  }
  String get email => _email;
  String get phone => _phone;
  String get avatarUrl => _avatarUrl;
  String get userState => _state;
  String get lga => _lga;
  String get address => _address;
  String get gender => _gender;
  String get bio => _bio;
  bool get isVerified => _isVerified;
  bool get isEmailVerified => _isEmailVerified;
  UserRole get role => _role;
  bool get isLandlord => _role == UserRole.landlord;
  double get profileCompletionPercentage => _profileCompletionPercentage;
  @override
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // --- AuthTokenProvider (used by the shared ApiClient for authed calls) ---
  @override
  Future<bool> refreshAccessToken() => refreshAuthToken();

  @override
  Future<void> onAuthFailure() => clearSession();
  UserModel? get currentUser => _userModel;
  LandlordProfile? get landlordProfile => _landlordProfile;
  TenantProfile? get tenantProfile => _tenantProfile;

  Future<void> setOnboardingCompleted() async {
    _hasCompletedOnboarding = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
    } catch (_) {}
    notifyListeners();
  }

  // Initialize Auth state from stored tokens & cached local user data
  Future<void> initAuth() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      final storedLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final storedUserJson = prefs.getString('user_data');

      if (storedUserJson != null && storedUserJson.isNotEmpty) {
        try {
          final uData = jsonDecode(storedUserJson);
          if (uData is Map<String, dynamic>) {
            _updateUserDataFromJson(uData, saveLocally: false);
          }
        } catch (_) {}
      }

      if (_accessToken != null && _accessToken!.isNotEmpty && storedLoggedIn) {
        _isLoggedIn = true;
      }
    } catch (_) {
    } finally {
      _isInitializing = false;
      notifyListeners();
    }

    // Now fetch fresh profile from API in background if logged in
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      try {
        final success = await fetchMe();
        if (!success && _refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshAuthToken();
          if (refreshed) {
            await fetchMe();
          }
        }
      } catch (_) {}
    }
  }

  // Fetch current user details via GET /api/me or GET /api/profile
  Future<bool> fetchMe() async {
    if (_accessToken == null || _accessToken!.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          _updateUserDataFromJson(data['user']);
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 401) {
        if (_refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshAuthToken();
          if (refreshed) {
            return await fetchMe();
          }
        }
        await clearSession();
        return false;
      }
    } catch (_) {}

    // Fallback: try GET /profile
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'] ?? data['user'];
        if (data['success'] == true && userData != null) {
          _updateUserDataFromJson(userData);
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  // Refresh access token via POST /api/auth/refresh
  Future<bool> refreshAuthToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccess = data['access_token'] as String?;
          final newRefresh = data['refresh_token'] as String?;
          if (newAccess != null) {
            await saveTokens(newAccess, newRefresh ?? _refreshToken!);
            return true;
          }
        }
      }
    } catch (_) {}

    return false;
  }

  // Login handler
  Future<AuthResponse> login(String emailInput, String passwordInput) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': emailInput.trim(),
              'password': passwordInput.trim(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final accessTok = data['access_token'] as String?;
        final refreshTok = data['refresh_token'] as String?;

        if (accessTok != null) {
          await saveTokens(accessTok, refreshTok ?? "");
          await fetchMe();
          _isLoggedIn = true;
          notifyListeners();

          return AuthResponse(
            success: true,
            message: data['message'] ?? "Login successful.",
            accessToken: accessTok,
            refreshToken: refreshTok,
          );
        }
      }

      final errMsg = data['message'] ?? "Invalid email or password.";
      return AuthResponse(success: false, message: errMsg);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: "Unable to connect to server. Please check your internet connection.",
      );
    }
  }

  // Register handler
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'first_name': firstName.trim(),
              'last_name': lastName.trim(),
              'mobile': phone.trim(),
              'email': email.trim(),
              'password': password.trim(),
              'type': role, // "user" or "agent"
            }),
          )
          .timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final accessTok = data['access_token'] as String?;
        final refreshTok = data['refresh_token'] as String?;

        if (accessTok != null && accessTok.isNotEmpty) {
          await saveTokens(accessTok, refreshTok ?? "");
          await fetchMe();
          _isLoggedIn = true;
          notifyListeners();
        }

        return AuthResponse(
          success: true,
          message: data['message'] ?? "Registration successful.",
          accessToken: accessTok,
          refreshToken: refreshTok,
        );
      }

      final errMsg = data['message'] ?? "Registration failed. Please check inputs.";
      return AuthResponse(success: false, message: errMsg);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: "Unable to connect to server. Please check your internet connection.",
      );
    }
  }

  // Verify Email via 6-digit OTP
  Future<AuthResponse> verifyEmail(String otpCode) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/email/verify'),
            headers: {
              'Content-Type': 'application/json',
              if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'email': _email,
              'otp': otpCode.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _isEmailVerified = true;
        _isVerified = true;
        notifyListeners();
        return AuthResponse(
          success: true,
          message: data['message'] ?? "Email verified successfully!",
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? "Invalid or expired verification code.",
      );
    } catch (_) {
      return AuthResponse(
        success: false,
        message: "Could not reach server to verify email. Please try again.",
      );
    }
  }

  // Resend verification OTP code
  Future<AuthResponse> resendVerificationEmail() async {
    if (_email.isEmpty) {
      return AuthResponse(success: false, message: "Email is required.");
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/email/resend'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': _email}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResponse(
          success: true,
          message: data['message'] ?? "A new verification code has been sent to $_email.",
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? "Failed to resend verification email.",
      );
    } catch (_) {
      return AuthResponse(
        success: false,
        message: "Failed to connect to server. Please try again.",
      );
    }
  }

  // Request password reset email
  Future<AuthResponse> requestPasswordReset(String emailInput) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/password/request'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': emailInput.trim()}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResponse(
          success: true,
          message: data['message'] ?? "Password reset link sent to your email.",
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? "Failed to request password reset.",
      );
    } catch (_) {
      return AuthResponse(
        success: false,
        message: "Failed to connect to server. Please try again.",
      );
    }
  }

  // Check if Email exists API
  Future<({bool available, String message})> checkEmailAvailability(
    String emailInput,
  ) async {
    final trimmed = emailInput.trim();
    if (trimmed.isEmpty || !trimmed.contains('@') || !trimmed.contains('.')) {
      return (available: false, message: 'Please enter a valid email address.');
    }
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/check/email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': trimmed}),
          )
          .timeout(const Duration(seconds: 6));

      final data = jsonDecode(response.body);
      final msg = data['message']?.toString();

      if (data['code'] == 'EMAIL_AVAILABLE' ||
          data['available'] == true ||
          (response.statusCode == 200 &&
              data['success'] == true &&
              data['code'] != 'EMAIL_TAKEN')) {
        return (
          available: true,
          message: msg ?? 'Email address is available.',
        );
      }

      if (data['code'] == 'EMAIL_TAKEN' ||
          data['available'] == false ||
          data['exists'] == true ||
          data['taken'] == true ||
          response.statusCode == 400 ||
          response.statusCode == 409) {
        return (
          available: false,
          message: msg ?? 'This email address is already registered.',
        );
      }
    } catch (_) {}
    return (available: true, message: '');
  }

  Future<bool> isEmailAvailable(String emailInput) async {
    final res = await checkEmailAvailability(emailInput);
    return res.available;
  }

  // Check if Phone exists API
  Future<({bool available, String message})> checkPhoneAvailability(
    String phoneInput,
  ) async {
    final trimmed = phoneInput.trim();
    if (trimmed.isEmpty || trimmed.length < 10) {
      return (
        available: false,
        message: 'Please enter a valid 11-digit phone number.',
      );
    }
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/check/phone'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'number': trimmed}),
          )
          .timeout(const Duration(seconds: 6));

      final data = jsonDecode(response.body);
      final msg = data['message']?.toString();

      if (data['code'] == 'PHONE_AVAILABLE' ||
          data['available'] == true ||
          (response.statusCode == 200 &&
              data['success'] == true &&
              data['code'] != 'PHONE_TAKEN')) {
        return (
          available: true,
          message: msg ?? 'Phone number is available.',
        );
      }

      if (data['code'] == 'PHONE_TAKEN' ||
          data['available'] == false ||
          data['exists'] == true ||
          data['taken'] == true ||
          response.statusCode == 400 ||
          response.statusCode == 409) {
        return (
          available: false,
          message: msg ?? 'This phone number is already registered.',
        );
      }
    } catch (_) {}
    return (available: true, message: '');
  }

  Future<bool> isPhoneAvailable(String phoneInput) async {
    final res = await checkPhoneAvailability(phoneInput);
    return res.available;
  }

  // Update profile information via PUT /api/users/:id
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? state,
    String? lga,
    String? address,
    String? gender,
    String? bio,
  }) async {
    if (firstName != null) _firstName = firstName.trim();
    if (lastName != null) _lastName = lastName.trim();
    if (phone != null) _phone = phone.trim();
    if (avatarUrl != null && avatarUrl.isNotEmpty) _avatarUrl = avatarUrl.trim();
    if (state != null) _state = state.trim();
    if (lga != null) _lga = lga.trim();
    if (address != null) _address = address.trim();
    if (gender != null) _gender = gender.trim();
    if (bio != null) _bio = bio.trim();

    if (_accessToken != null && _accessToken!.isNotEmpty && _id.isNotEmpty) {
      try {
        final response = await http
            .put(
              Uri.parse('$baseUrl/users/$_id'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_accessToken',
              },
              body: jsonEncode({
                'first_name': _firstName,
                'last_name': _lastName,
                'mobile': _phone,
                'state': _state,
                'lga': _lga,
                'occupation': _bio,
                'bio': _bio,
                'address': _address,
                'gender': _gender,
                if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar': _avatarUrl,
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] != null) {
            _updateUserDataFromJson(data['data']);
          } else if (data['success'] == true && data['user'] != null) {
            _updateUserDataFromJson(data['user']);
          }
        }
      } catch (e) {
        debugPrint("Error updating user profile on backend API: $e");
      }
    }

    _saveUserDataLocally({
      'id': _id,
      'first_name': _firstName,
      'last_name': _lastName,
      'email': _email,
      'mobile': _phone,
      'type': isLandlord ? 'agent' : 'user',
      'email_verified': _isEmailVerified,
      'avatar': _avatarUrl,
      'state': _state,
      'lga': _lga,
      'address': _address,
      'gender': _gender,
      'bio': _bio,
      'occupation': _bio,
    });

    notifyListeners();
    return true;
  }

  // Upload profile picture file via POST /api/users/:id/avatar
  Future<AuthResponse> uploadAvatarFile(XFile file) async {
    if (_accessToken == null || _accessToken!.isEmpty || _id.isEmpty) {
      return AuthResponse(success: false, message: "User is not logged in.");
    }

    try {
      final uri = Uri.parse('$baseUrl/users/$_id/avatar');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $_accessToken';

      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name.isNotEmpty ? file.name : 'avatar.jpg',
      );

      request.files.add(multipartFile);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final newAvatar = data['avatar'] as String?;
        if (newAvatar != null && newAvatar.isNotEmpty) {
          _avatarUrl = newAvatar;
          notifyListeners();
          await fetchMe();
          return AuthResponse(
            success: true,
            message: data['message'] ?? "Profile photo uploaded successfully!",
          );
        }
      }
      return AuthResponse(
        success: false,
        message: data['message'] ?? "Failed to upload profile picture.",
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message:
            "Failed to upload image. Please check your network connection.",
      );
    }
  }

  // Change user password
  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return AuthResponse(success: false, message: "User is not logged in.");
    }

    // Try PUT /auth/change/password
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/change/password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'current_password': currentPassword.trim(),
              'new_password': newPassword.trim(),
              'password': newPassword.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return AuthResponse(
          success: true,
          message: data['message'] ?? "Password updated successfully!",
        );
      }
    } catch (_) {}

    // Fallback: POST /auth/password/change
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/password/change'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'current_password': currentPassword.trim(),
              'new_password': newPassword.trim(),
              'password': newPassword.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return AuthResponse(
          success: true,
          message: data['message'] ?? "Password updated successfully!",
        );
      }
      return AuthResponse(
        success: false,
        message:
            data['message'] ??
            "Failed to change password. Please verify your current password.",
      );
    } catch (_) {
      return AuthResponse(
        success: false,
        message: "Failed to connect to server. Please try again.",
      );
    }
  }

  // Deactivate user account
  Future<AuthResponse> deactivateAccount({
    String? currentPassword,
    String? reason,
  }) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return AuthResponse(success: false, message: "User is not logged in.");
    }

    // Try POST /users/deactivate (Go backend)
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/deactivate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({
              'password': currentPassword ?? "",
              'confirmation': "deactivate my account",
              'reason': reason ?? "User requested account deactivation",
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      await clearSession();
      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResponse(
          success: true,
          message: data['message'] ?? "Account deactivated successfully.",
        );
      }
    } catch (_) {}

    // Fallback: POST /auth/deactivate
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'reason': reason ?? "User requested account deactivation",
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    await clearSession();
    return AuthResponse(
      success: true,
      message: "Account deactivated successfully.",
    );
  }

  // Save tokens to SharedPreferences
  Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    _isLoggedIn = true;
    _hasCompletedOnboarding = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', access);
      await prefs.setString('refresh_token', refresh);
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('has_completed_onboarding', true);
    } catch (_) {}
  }

  // Clear storage and reset session
  Future<void> clearSession() async {
    _isLoggedIn = false;
    _accessToken = null;
    _refreshToken = null;
    _id = "";
    _firstName = "";
    _lastName = "";
    _email = "";
    _phone = "";
    _isEmailVerified = false;
    _isVerified = false;
    _state = "Lagos";
    _lga = "Ikeja";
    _address = "";
    _gender = "Male";
    _bio = "";

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('is_logged_in');
      await prefs.remove('user_data');
    } catch (_) {}

    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    await clearSession();
  }

  // Helper method to parse API user response
  void _updateUserDataFromJson(
    Map<String, dynamic> u, {
    bool saveLocally = true,
  }) {
    _id = u['id']?.toString() ?? _id;
    _firstName = u['first_name']?.toString() ?? _firstName;
    _lastName = u['last_name']?.toString() ?? _lastName;
    _email = u['email']?.toString() ?? _email;
    _phone = (u['mobile'] ?? u['phone'])?.toString() ?? _phone;

    final avatar = u['avatar']?.toString();
    if (avatar != null && avatar.isNotEmpty) {
      _avatarUrl = avatar;
    }

    final typeStr = u['type']?.toString().toLowerCase();
    if (typeStr == 'agent' || typeStr == 'landlord') {
      _role = UserRole.landlord;
    } else {
      _role = UserRole.tenant;
    }

    if (u.containsKey('email_verified') && u['email_verified'] != null) {
      _isEmailVerified = u['email_verified'] == true;
    }
    _isVerified = _isEmailVerified;
    _profileCompletionPercentage = _isEmailVerified ? 0.95 : 0.70;

    if (u['state'] != null && u['state'].toString().isNotEmpty) {
      _state = u['state'].toString();
    }
    if (u['lga'] != null && u['lga'].toString().isNotEmpty) {
      _lga = u['lga'].toString();
    }
    if (u['address'] != null && u['address'].toString().isNotEmpty) {
      _address = u['address'].toString();
    }
    if (u['gender'] != null && u['gender'].toString().isNotEmpty) {
      _gender = u['gender'].toString();
    }
    if (u['bio'] != null && u['bio'].toString().isNotEmpty) {
      _bio = u['bio'].toString();
    } else if (u['occupation'] != null && u['occupation'].toString().isNotEmpty) {
      _bio = u['occupation'].toString();
    }

    // Check embedded profiles from Go backend: LandlordProfile and TenantProfile
    final lp = u['landlord_profile'];
    if (lp is Map<String, dynamic>) {
      _landlordProfile = LandlordProfile.fromJson(lp);
      if (lp['state'] != null && lp['state'].toString().isNotEmpty) {
        _state = lp['state'].toString();
      }
      if (lp['lga'] != null && lp['lga'].toString().isNotEmpty) {
        _lga = lp['lga'].toString();
      }
    } else {
      _landlordProfile = null;
    }

    final tp = u['tenant_profile'];
    if (tp is Map<String, dynamic>) {
      _tenantProfile = TenantProfile.fromJson(tp);
      if (tp['state'] != null && tp['state'].toString().isNotEmpty) {
        _state = tp['state'].toString();
      }
      if (tp['lga'] != null && tp['lga'].toString().isNotEmpty) {
        _lga = tp['lga'].toString();
      }
      if (tp['occupation'] != null && tp['occupation'].toString().isNotEmpty) {
        _bio = tp['occupation'].toString();
      }
    } else {
      _tenantProfile = null;
    }

    try {
      _userModel = UserModel.fromJson(u);
    } catch (_) {}

    if (saveLocally) {
      _saveUserDataLocally(u);
    }
  }

  Future<void> _saveUserDataLocally(Map<String, dynamic> u) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(u));
    } catch (_) {}
  }
}
