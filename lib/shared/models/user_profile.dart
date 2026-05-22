import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class UserProfile extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const UserProfile({
    required this.id,
    this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.createdAt,
    this.metadata,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String? ?? json['fullName'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      role: UserRoleX.fromString(json['role'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role.value,
        'metadata': metadata,
      };

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    UserRole? role,
  }) {
    return UserProfile(
      id: id,
      email: email,
      phone: phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, phone, fullName, avatarUrl, role, createdAt];
}
