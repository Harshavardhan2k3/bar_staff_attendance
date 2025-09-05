class LeaveBalance {
  final String id;
  final String userId;
  final int year;
  final int sickLeaveTotal;
  final int sickLeaveUsed;
  final int vacationLeaveTotal;
  final int vacationLeaveUsed;
  final int personalLeaveTotal;
  final int personalLeaveUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveBalance({
    required this.id,
    required this.userId,
    required this.year,
    required this.sickLeaveTotal,
    required this.sickLeaveUsed,
    required this.vacationLeaveTotal,
    required this.vacationLeaveUsed,
    required this.personalLeaveTotal,
    required this.personalLeaveUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      year: json['year'] as int,
      sickLeaveTotal: json['sick_leave_total'] as int,
      sickLeaveUsed: json['sick_leave_used'] as int,
      vacationLeaveTotal: json['vacation_leave_total'] as int,
      vacationLeaveUsed: json['vacation_leave_used'] as int,
      personalLeaveTotal: json['personal_leave_total'] as int,
      personalLeaveUsed: json['personal_leave_used'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'year': year,
      'sick_leave_total': sickLeaveTotal,
      'sick_leave_used': sickLeaveUsed,
      'vacation_leave_total': vacationLeaveTotal,
      'vacation_leave_used': vacationLeaveUsed,
      'personal_leave_total': personalLeaveTotal,
      'personal_leave_used': personalLeaveUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get totalLeaveEntitlement {
    return sickLeaveTotal + vacationLeaveTotal + personalLeaveTotal;
  }

  int get totalLeaveUsed {
    return sickLeaveUsed + vacationLeaveUsed + personalLeaveUsed;
  }

  int get totalLeaveRemaining {
    return totalLeaveEntitlement - totalLeaveUsed;
  }

  int get sickLeaveRemaining => sickLeaveTotal - sickLeaveUsed;
  int get vacationLeaveRemaining => vacationLeaveTotal - vacationLeaveUsed;
  int get personalLeaveRemaining => personalLeaveTotal - personalLeaveUsed;

  double get utilizationPercentage {
    if (totalLeaveEntitlement == 0) return 0.0;
    return (totalLeaveUsed / totalLeaveEntitlement) * 100;
  }

  bool get hasRemainingLeave => totalLeaveRemaining > 0;

  LeaveBalance copyWith({
    String? id,
    String? userId,
    int? year,
    int? sickLeaveTotal,
    int? sickLeaveUsed,
    int? vacationLeaveTotal,
    int? vacationLeaveUsed,
    int? personalLeaveTotal,
    int? personalLeaveUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveBalance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      sickLeaveTotal: sickLeaveTotal ?? this.sickLeaveTotal,
      sickLeaveUsed: sickLeaveUsed ?? this.sickLeaveUsed,
      vacationLeaveTotal: vacationLeaveTotal ?? this.vacationLeaveTotal,
      vacationLeaveUsed: vacationLeaveUsed ?? this.vacationLeaveUsed,
      personalLeaveTotal: personalLeaveTotal ?? this.personalLeaveTotal,
      personalLeaveUsed: personalLeaveUsed ?? this.personalLeaveUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
