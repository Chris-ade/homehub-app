import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../data/mock_data.dart';

class BookingProvider extends ChangeNotifier {
  final List<InspectionBooking> _bookings = List.from(MockData.initialBookings);
  final List<LeaseAgreement> _leases = List.from(MockData.initialLeases);

  List<InspectionBooking> get bookings => _bookings;
  List<LeaseAgreement> get leases => _leases;

  void addBooking(InspectionBooking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index].status = InspectionStatus.cancelled;
      notifyListeners();
    }
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
