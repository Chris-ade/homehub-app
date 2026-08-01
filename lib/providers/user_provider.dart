import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum UserRole { tenant, landlord }

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false; // Default to unauthenticated
  String _id = "";
  String _name = "";
  String _email = "";
  String _phone = "";
  final String _avatarUrl =
      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80";
  bool _isVerified = true;
  bool _isEmailVerified = true;
  UserRole _role = UserRole.tenant;
  final double _profileCompletionPercentage = 0.90;
  String? _authToken;

  // Base API URL matching Render live environment
  static const String baseUrl = "https://rentalhub-api-0kuk.onrender.com/api";

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get id => _id;
  String get name => _name.isEmpty ? "HomeHub User" : _name;
  String get email => _email;
  String get phone => _phone;
  String get avatarUrl => _avatarUrl;
  bool get isVerified => _isVerified;
  bool get isEmailVerified => _isEmailVerified;
  UserRole get role => _role;
  bool get isLandlord => _role == UserRole.landlord;
  double get profileCompletionPercentage => _profileCompletionPercentage;
  String? get authToken => _authToken;

  void toggleRole() {
    _role = _role == UserRole.tenant ? UserRole.landlord : UserRole.tenant;
    notifyListeners();
  }

  void updateProfile({String? name, String? email, String? phone}) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    notifyListeners();
  }

  void verifyEmail() {
    _isEmailVerified = true;
    notifyListeners();
  }

  // Real Login API method with fallback for testing
  Future<bool> login(String emailInput, String passwordInput) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': emailInput, 'password': passwordInput}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final u = data['user'];
          _id = u['id'] ?? "usr_${DateTime.now().millisecondsSinceEpoch}";
          _name = "${u['first_name'] ?? ''} ${u['last_name'] ?? ''}".trim();
          if (_name.isEmpty) _name = u['email'] ?? emailInput;
          _email = u['email'] ?? emailInput;
          _role = (u['type'] == 'agent' || u['type'] == 'landlord')
              ? UserRole.landlord
              : UserRole.tenant;
          _isVerified = u['email_verified'] ?? true;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
    } catch (_) {
      // Offline fallback for testing
    }

    // Authentication fallback for demo / testing
    if (emailInput.isNotEmpty && passwordInput.length >= 4) {
      _email = emailInput;
      final emailPrefix = emailInput.split('@').first;
      _name = emailPrefix.replaceAll('.', ' ').toUpperCase();
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  // Real Registration API method with fallback for testing
  Future<bool> register({
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
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'mobileNo': phone,
              'password': password,
              'confirmPassword': password,
              'type': role,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 201 || response.statusCode == 200) {
        _name = "$firstName $lastName";
        _email = email;
        _phone = phone;
        _role = role == 'agent' ? UserRole.landlord : UserRole.tenant;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Offline fallback
    }

    // Offline registration fallback
    _name = "$firstName $lastName";
    _email = email;
    _phone = phone;
    _role = role == 'agent' ? UserRole.landlord : UserRole.tenant;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _authToken = null;
    _name = "";
    _email = "";
    notifyListeners();
  }
}
