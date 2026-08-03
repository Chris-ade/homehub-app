// Dart data models for HomeHub User, Landlord Profile, Tenant Profile, and Auth responses.
// Aligned with the Web frontend TypeScript interfaces and shared Go backend API schema.

class LandlordProfile {
  final String id;
  final String? representativeType;
  final String? businessName;
  final String? governmentIdUrl;
  final String verificationStatus;
  final String? state;
  final String? lga;
  final double? rating;
  final String responseTime;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankCode;
  final bool payoutEnabled;

  LandlordProfile({
    required this.id,
    this.representativeType,
    this.businessName,
    this.governmentIdUrl,
    this.verificationStatus = 'unverified',
    this.state,
    this.lga,
    this.rating,
    this.responseTime = 'Within 24 hours',
    this.bankName,
    this.bankAccountNumber,
    this.bankCode,
    this.payoutEnabled = false,
  });

  factory LandlordProfile.fromJson(Map<String, dynamic> json) {
    double? parsedRating;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else if (json['rating'] is String) {
        parsedRating = double.tryParse(json['rating']);
      }
    }

    return LandlordProfile(
      id: json['id']?.toString() ?? '',
      representativeType: json['representative_type']?.toString(),
      businessName: json['business_name']?.toString(),
      governmentIdUrl: json['government_id_url']?.toString(),
      verificationStatus: json['verification_status']?.toString() ?? 'unverified',
      state: json['state']?.toString(),
      lga: json['lga']?.toString(),
      rating: parsedRating,
      responseTime: json['response_time']?.toString() ?? 'Within 24 hours',
      bankName: json['bank_name']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      bankCode: json['bank_code']?.toString(),
      payoutEnabled: json['payout_enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'representative_type': representativeType,
        'business_name': businessName,
        'government_id_url': governmentIdUrl,
        'verification_status': verificationStatus,
        'state': state,
        'lga': lga,
        'rating': rating,
        'response_time': responseTime,
        'bank_name': bankName,
        'bank_account_number': bankAccountNumber,
        'bank_code': bankCode,
        'payout_enabled': payoutEnabled,
      };
}

class TenantProfile {
  final String id;
  final String? occupation;
  final String? employmentStatus;
  final String? state;
  final String? lga;
  final String? guarantorName;
  final String? guarantorPhone;
  final String? preferredState;
  final String? preferredLga;

  TenantProfile({
    required this.id,
    this.occupation,
    this.employmentStatus,
    this.state,
    this.lga,
    this.guarantorName,
    this.guarantorPhone,
    this.preferredState,
    this.preferredLga,
  });

  factory TenantProfile.fromJson(Map<String, dynamic> json) {
    return TenantProfile(
      id: json['id']?.toString() ?? '',
      occupation: json['occupation']?.toString(),
      employmentStatus: json['employment_status']?.toString(),
      state: json['state']?.toString(),
      lga: json['lga']?.toString(),
      guarantorName: json['guarantor_name']?.toString(),
      guarantorPhone: json['guarantor_phone']?.toString(),
      preferredState: json['preferred_state']?.toString(),
      preferredLga: json['preferred_lga']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'occupation': occupation,
        'employment_status': employmentStatus,
        'state': state,
        'lga': lga,
        'guarantor_name': guarantorName,
        'guarantor_phone': guarantorPhone,
        'preferred_state': preferredState,
        'preferred_lga': preferredLga,
      };
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String type; // "user" or "agent" or "admin"
  final String? mobile;
  final String? avatar;
  final String? image;
  final String? lga;
  final String? state;
  final String? occupation;
  final double? landlordRating;
  final String? responseTime;
  final bool landlordVerified;
  final bool emailVerified;
  final LandlordProfile? landlordProfile;
  final TenantProfile? tenantProfile;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.type,
    this.mobile,
    this.avatar,
    this.image,
    this.lga,
    this.state,
    this.occupation,
    this.landlordRating,
    this.responseTime,
    this.landlordVerified = false,
    this.emailVerified = false,
    this.landlordProfile,
    this.tenantProfile,
    this.createdAt,
  });

  String get fullName => "$firstName $lastName".trim();

  bool get isLandlord =>
      type.toLowerCase() == 'agent' || type.toLowerCase() == 'landlord';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    double? parsedRating;
    if (json['landlord_rating'] != null) {
      if (json['landlord_rating'] is num) {
        parsedRating = (json['landlord_rating'] as num).toDouble();
      } else if (json['landlord_rating'] is String) {
        parsedRating = double.tryParse(json['landlord_rating']);
      }
    }

    LandlordProfile? lProfile;
    if (json['landlord_profile'] != null &&
        json['landlord_profile'] is Map<String, dynamic>) {
      lProfile = LandlordProfile.fromJson(
          json['landlord_profile'] as Map<String, dynamic>);
    }

    TenantProfile? tProfile;
    if (json['tenant_profile'] != null &&
        json['tenant_profile'] is Map<String, dynamic>) {
      tProfile = TenantProfile.fromJson(
          json['tenant_profile'] as Map<String, dynamic>);
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      type: json['type']?.toString() ?? 'user',
      mobile: json['mobile']?.toString(),
      avatar: json['avatar']?.toString() ?? json['image']?.toString(),
      image: json['image']?.toString(),
      lga: json['lga']?.toString(),
      state: json['state']?.toString(),
      occupation: json['occupation']?.toString(),
      landlordRating: parsedRating,
      responseTime: json['response_time']?.toString(),
      landlordVerified: json['landlord_verified'] == true ||
          lProfile?.verificationStatus == 'verified',
      emailVerified: json['email_verified'] == true,
      landlordProfile: lProfile,
      tenantProfile: tProfile,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'type': type,
        'mobile': mobile,
        'avatar': avatar,
        'image': image,
        'lga': lga,
        'state': state,
        'occupation': occupation,
        'landlord_rating': landlordRating,
        'response_time': responseTime,
        'landlord_verified': landlordVerified,
        'email_verified': emailVerified,
        'landlord_profile': landlordProfile?.toJson(),
        'tenant_profile': tenantProfile?.toJson(),
        'created_at': createdAt,
      };
}

class RegisterData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final String? type;
  final String? lga;
  final String? state;
  final String? occupation;

  RegisterData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    this.type = 'user',
    this.lga,
    this.state,
    this.occupation,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'mobile': mobile,
        'type': type,
        if (lga != null) 'lga': lga,
        if (state != null) 'state': state,
        if (occupation != null) 'occupation': occupation,
      };
}

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final dynamic errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'],
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data,
        'errors': errors,
      };
}
