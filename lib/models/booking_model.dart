enum InspectionStatus { pending, confirmed, completed, cancelled }

enum EscrowStatus { pending, inEscrow, released, refunded }

class InspectionBooking {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyImage;
  final String area;
  final String agentName;
  final String agentPhone;
  final DateTime date;
  final String timeSlot; // '10:00 AM', '02:00 PM', '04:30 PM'
  final String inspectionType; // 'In-Person Viewing' or '3D Virtual Tour'
  InspectionStatus status;
  final String note;

  InspectionBooking({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyImage,
    required this.area,
    required this.agentName,
    required this.agentPhone,
    required this.date,
    required this.timeSlot,
    this.inspectionType = "In-Person Viewing",
    this.status = InspectionStatus.confirmed,
    this.note = "",
  });
}

class LeaseAgreement {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String area;
  final double annualRent;
  final double securityDeposit;
  final double serviceCharge;
  final DateTime startDate;
  final int durationMonths;
  bool isSigned;
  String? signatureText;
  DateTime? signedAt;
  EscrowStatus escrowStatus;

  LeaseAgreement({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.area,
    required this.annualRent,
    this.securityDeposit = 100000,
    this.serviceCharge = 0, // 0% agent fees on HomeHub!
    required this.startDate,
    this.durationMonths = 12,
    this.isSigned = false,
    this.signatureText,
    this.signedAt,
    this.escrowStatus = EscrowStatus.pending,
  });

  double get totalAmount => annualRent + securityDeposit + serviceCharge;
}
