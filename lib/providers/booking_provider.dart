import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../services/api_client.dart';
import '../data/mock_data.dart';
import 'user_provider.dart';

class BookingProvider extends ChangeNotifier {
  final ApiClient _api;

  BookingProvider(this._api);

  final List<InspectionBooking> _bookings = [];
  final List<LeaseAgreement> _leases = List.from(MockData.initialLeases);

  bool _isLoading = false;
  String? _error;
  String _currentUserId = "";

  List<InspectionBooking> get bookings => _bookings;
  List<LeaseAgreement> get leases => _leases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void bindUser(UserProvider user) {
    final token = user.accessToken;
    final loggedIn =
        user.isLoggedIn && token != null && token.isNotEmpty && user.id.isNotEmpty;

    if (loggedIn) {
      if (_currentUserId != user.id) {
        _currentUserId = user.id;
        fetchBookings();
      }
    } else {
      if (_currentUserId.isNotEmpty || _bookings.isNotEmpty) {
        _currentUserId = "";
        _bookings.clear();
        notifyListeners();
      }
    }
  }

  Future<void> fetchBookings({String role = "all"}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/inspections?role=$role', auth: true);
      if (res.ok) {
        final list = _extractList(res.data);
        if (list != null) {
          final fetched = <InspectionBooking>[];
          for (final item in list) {
            if (item is Map) {
              try {
                fetched.add(
                  InspectionBooking.fromJson(Map<String, dynamic>.from(item)),
                );
              } catch (_) {}
            }
          }
          _bookings
            ..clear()
            ..addAll(fetched);
        }
      } else {
        _error = "Could not load inspections.";
      }
    } catch (_) {
      _error = "Failed to connect to server.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<InspectionBooking?> bookInspection({
    required String propertyId,
    required DateTime date,
    required String timeSlot,
    String type = "In-Person Viewing",
    String notes = "",
    String? fallbackPropertyTitle,
    String? fallbackPropertyImage,
    String? fallbackArea,
    String? fallbackAgentName,
    String? fallbackAgentPhone,
  }) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final backendType =
          (type.toLowerCase().contains("virtual") || type == "virtual")
              ? "virtual"
              : "in_person";

      final body = {
        'property_id': propertyId,
        'date': formattedDate,
        'time_slot': timeSlot,
        'type': backendType,
        if (notes.isNotEmpty) 'notes': notes,
      };

      final res = await _api.post('/inspections', body: body, auth: true);
      if (res.isSuccess && res.data is Map) {
        final dataMap = res.data['data'] is Map
            ? res.data['data'] as Map<String, dynamic>
            : null;
        if (dataMap != null) {
          final booking = InspectionBooking.fromJson(dataMap);
          _bookings.insert(0, booking);
          notifyListeners();
          return booking;
        }
      }

      // Fallback local addition if server error/offline
      final fallbackBooking = InspectionBooking(
        id: "bk-${DateTime.now().millisecondsSinceEpoch}",
        propertyId: propertyId,
        propertyTitle: fallbackPropertyTitle ?? "Property Inspection",
        propertyImage: fallbackPropertyImage ??
            "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200",
        area: fallbackArea ?? "Nigeria",
        agentName: fallbackAgentName ?? "Host",
        agentPhone: fallbackAgentPhone ?? "",
        date: date,
        timeSlot: timeSlot,
        inspectionType: type,
        status: InspectionStatus.pending,
        note: notes,
      );
      _bookings.insert(0, fallbackBooking);
      notifyListeners();
      return fallbackBooking;
    } catch (_) {
      return null;
    }
  }

  void addBooking(InspectionBooking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final res = await _api.patch(
        '/inspections/$bookingId/status',
        body: {'status': 'cancelled'},
        auth: true,
      );

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index].status = InspectionStatus.cancelled;
        notifyListeners();
      }

      return res.ok || res.isSuccess;
    } catch (_) {
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index].status = InspectionStatus.cancelled;
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  Future<bool> updateStatus(String bookingId, InspectionStatus status) async {
    try {
      final res = await _api.patch(
        '/inspections/$bookingId/status',
        body: {'status': status.name},
        auth: true,
      );

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index].status = status;
        notifyListeners();
      }

      return res.ok || res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rescheduleBooking(
    String bookingId,
    DateTime newDate,
    String newTimeSlot, {
    String notes = "",
  }) async {
    try {
      final res = await _api.post(
        '/inspections/$bookingId/reschedule',
        body: {
          'date': DateFormat('yyyy-MM-dd').format(newDate),
          'time_slot': newTimeSlot,
          if (notes.isNotEmpty) 'notes': notes,
        },
        auth: true,
      );

      if (res.ok || res.isSuccess) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  List<dynamic>? _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['inspections'] is List) return data['inspections'] as List;
      if (data['bookings'] is List) return data['bookings'] as List;
    }
    return null;
  }

  LeaseAgreement? getLeaseByPropertyId(String propertyId) {
    try {
      return _leases.firstWhere((l) => l.propertyId == propertyId);
    } catch (_) {
      return null;
    }
  }

  void createOrUpdateLease({
    required String propertyId,
    required String propertyTitle,
    required String area,
    required double annualRent,
    required String signatureText,
  }) {
    final existingIndex = _leases.indexWhere((l) => l.propertyId == propertyId);
    if (existingIndex != -1) {
      _leases[existingIndex].isSigned = true;
      _leases[existingIndex].signatureText = signatureText;
      _leases[existingIndex].signedAt = DateTime.now();
      _leases[existingIndex].escrowStatus = EscrowStatus.inEscrow;
    } else {
      final newLease = LeaseAgreement(
        id: "ls-${DateTime.now().millisecondsSinceEpoch}",
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        area: area,
        annualRent: annualRent,
        startDate: DateTime.now().add(const Duration(days: 7)),
        isSigned: true,
        signatureText: signatureText,
        signedAt: DateTime.now(),
        escrowStatus: EscrowStatus.inEscrow,
      );
      _leases.insert(0, newLease);
    }
    notifyListeners();
  }

  void updateEscrowStatus(String leaseId, EscrowStatus status) {
    final index = _leases.indexWhere((l) => l.id == leaseId);
    if (index != -1) {
      _leases[index].escrowStatus = status;
      notifyListeners();
    }
  }
}
