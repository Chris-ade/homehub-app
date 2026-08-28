enum InspectionStatus { pending, confirmed, completed, cancelled, rescheduled }

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

  factory InspectionBooking.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']?.toString() ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final propMap = json['property'] is Map ? json['property'] as Map<String, dynamic> : null;
    final landlordMap = json['landlord'] is Map ? json['landlord'] as Map<String, dynamic> : null;

    final String propTitle = propMap?['title']?.toString() ?? json['property_title']?.toString() ?? 'Property Inspection';
    final String propImg = propMap?['image']?.toString() ??
        (propMap?['images'] is List && (propMap!['images'] as List).isNotEmpty
            ? (propMap['images'][0] is Map ? propMap['images'][0]['url']?.toString() : propMap['images'][0]?.toString())
            : null) ??
        json['property_image']?.toString() ??
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200';

    final String propArea = propMap?['city'] != null && propMap?['state'] != null
        ? "${propMap!['city']}, ${propMap['state']}"
        : (propMap?['address']?.toString() ?? json['area']?.toString() ?? 'Nigeria');

    final String hostName = landlordMap != null
        ? "${landlordMap['first_name'] ?? ''} ${landlordMap['last_name'] ?? ''}".trim()
        : (json['agent_name']?.toString() ?? 'Host');
    final String hostPhone = landlordMap?['phone']?.toString() ?? json['agent_phone']?.toString() ?? '';

    final statusStr = json['status']?.toString().toLowerCase() ?? 'pending';
    InspectionStatus parsedStatus;
    switch (statusStr) {
      case 'confirmed':
        parsedStatus = InspectionStatus.confirmed;
        break;
      case 'completed':
        parsedStatus = InspectionStatus.completed;
        break;
      case 'cancelled':
        parsedStatus = InspectionStatus.cancelled;
        break;
      case 'rescheduled':
        parsedStatus = InspectionStatus.rescheduled;
        break;
      default:
        parsedStatus = InspectionStatus.pending;
    }

    final typeStr = json['type']?.toString().toLowerCase() ?? 'in_person';
    final inspectionType = typeStr.contains('virtual') ? '3D Virtual Tour' : 'In-Person Viewing';

    return InspectionBooking(
      id: json['id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? propMap?['id']?.toString() ?? '',
      propertyTitle: propTitle,
      propertyImage: propImg,
      area: propArea,
      agentName: hostName.isNotEmpty ? hostName : 'Host',
      agentPhone: hostPhone,
      date: parsedDate,
      timeSlot: json['time_slot']?.toString() ?? '10:00 AM',
      inspectionType: inspectionType,
      status: parsedStatus,
      note: json['notes']?.toString() ?? json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property_title': propertyTitle,
      'property_image': propertyImage,
      'area': area,
      'agent_name': agentName,
      'agent_phone': agentPhone,
      'date': date.toIso8601String().split('T')[0],
      'time_slot': timeSlot,
      'type': inspectionType.contains('Virtual') ? 'virtual' : 'in_person',
      'status': status.name,
      'notes': note,
    };
  }
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
