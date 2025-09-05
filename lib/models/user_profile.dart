class UserProfile {
  final String id;
  final String employeeId;
  final String email;
  final String fullName;
  final String role;
  final String? position;
  final String? department;
  final String? phoneNumber;
  final DateTime? hireDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.employeeId,
    required this.email,
    required this.fullName,
    required this.role,
    this.position,
    this.department,
    this.phoneNumber,
    this.hireDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      position: json['position'] as String?,
      department: json['department'] as String?,
      phoneNumber: json['phone_number'] as String?,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'email': email,
      'full_name': fullName,
      'role': role,
      'position': position,
      'department': department,
      'phone_number': phoneNumber,
      'hire_date': hireDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? employeeId,
    String? email,
    String? fullName,
    String? role,
    String? position,
    String? department,
    String? phoneNumber,
    DateTime? hireDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      position: position ?? this.position,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
