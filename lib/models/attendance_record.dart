class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final String? scheduledStart;
  final String? scheduledEnd;
  final double totalHours;
  final String status;
  final double? locationLat;
  final double? locationLng;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    this.scheduledStart,
    this.scheduledEnd,
    this.totalHours = 0.0,
    required this.status,
    this.locationLat,
    this.locationLng,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      clockInTime: json['clock_in_time'] != null
          ? DateTime.parse(json['clock_in_time'] as String)
          : null,
      clockOutTime: json['clock_out_time'] != null
          ? DateTime.parse(json['clock_out_time'] as String)
          : null,
      scheduledStart: json['scheduled_start'] as String?,
      scheduledEnd: json['scheduled_end'] as String?,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'clock_in_time': clockInTime?.toIso8601String(),
      'clock_out_time': clockOutTime?.toIso8601String(),
      'scheduled_start': scheduledStart,
      'scheduled_end': scheduledEnd,
      'total_hours': totalHours,
      'status': status,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
    return "${_getMonthName(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  String get clockInTimeFormatted {
    if (clockInTime == null) return '--:--';
    return "${clockInTime!.hour.toString().padLeft(2, '0')}:${clockInTime!.minute.toString().padLeft(2, '0')} ${clockInTime!.hour >= 12 ? 'PM' : 'AM'}";
  }

  String get clockOutTimeFormatted {
    if (clockOutTime == null) return '--:--';
    return "${clockOutTime!.hour.toString().padLeft(2, '0')}:${clockOutTime!.minute.toString().padLeft(2, '0')} ${clockOutTime!.hour >= 12 ? 'PM' : 'AM'}";
  }

  String get totalHoursFormatted {
    return totalHours.toStringAsFixed(1);
  }

  bool get isPresent =>
      status == 'present' || status == 'late' || status == 'early';

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  AttendanceRecord copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    String? scheduledStart,
    String? scheduledEnd,
    double? totalHours,
    String? status,
    double? locationLat,
    double? locationLng,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
