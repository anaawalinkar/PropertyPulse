class TourScheduleModel {
  final String id;
  final String propertyId;
  final String sellerId;
  final String buyerId;
  final TourType tourType;
  final DateTime scheduledDateTime;
  final DateTime? endDateTime;
  final TourStatus status;
  final String? notes;
  final String? meetingLink; // For virtual tours
  final String? meetingLocation; // For in-person tours
  final DateTime createdAt;
  final DateTime updatedAt;

  TourScheduleModel({
    required this.id,
    required this.propertyId,
    required this.sellerId,
    required this.buyerId,
    required this.tourType,
    required this.scheduledDateTime,
    this.endDateTime,
    required this.status,
    this.notes,
    this.meetingLink,
    this.meetingLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'tourType': tourType.toString().split('.').last,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'meetingLink': meetingLink,
      'meetingLocation': meetingLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TourScheduleModel.fromMap(Map<String, dynamic> map) {
    return TourScheduleModel(
      id: map['id'] ?? '',
      propertyId: map['propertyId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      tourType: TourType.values.firstWhere(
        (e) => e.toString().split('.').last == map['tourType'],
        orElse: () => TourType.virtual,
      ),
      scheduledDateTime: DateTime.parse(map['scheduledDateTime']),
      endDateTime: map['endDateTime'] != null 
          ? DateTime.parse(map['endDateTime']) 
          : null,
      status: TourStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TourStatus.pending,
      ),
      notes: map['notes'],
      meetingLink: map['meetingLink'],
      meetingLocation: map['meetingLocation'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  TourScheduleModel copyWith({
    String? id,
    String? propertyId,
    String? sellerId,
    String? buyerId,
    TourType? tourType,
    DateTime? scheduledDateTime,
    DateTime? endDateTime,
    TourStatus? status,
    String? notes,
    String? meetingLink,
    String? meetingLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TourScheduleModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      tourType: tourType ?? this.tourType,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      meetingLink: meetingLink ?? this.meetingLink,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TourType {
  virtual,
  inPerson,
}

enum TourStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

