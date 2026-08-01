import 'package:flutter/material.dart';

enum UserRole { tenant, landlord }

class UserProvider extends ChangeNotifier {
  String _name = "Oluwaseun Adebayo";
  String _email = "seun.adebayo@example.com";
  String _phone = "+234 802 345 6789";
  String _avatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80";
  bool _isVerified = true;
  bool _isEmailVerified = true;
  UserRole _role = UserRole.tenant;
  double _profileCompletionPercentage = 0.90;

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get avatarUrl => _avatarUrl;
  bool get isVerified => _isVerified;
  bool get isEmailVerified => _isEmailVerified;
  UserRole get role => _role;
  bool get isLandlord => _role == UserRole.landlord;
  double get profileCompletionPercentage => _profileCompletionPercentage;

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
}
