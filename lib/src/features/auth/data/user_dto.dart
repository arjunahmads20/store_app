import 'package:store_app/src/features/auth/domain/user.dart';

class UserDto {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final String? gender;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String? status;
  final int dailyProductQuota;

  UserDto({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
    this.status,
    required this.dailyProductQuota,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String?,
      dailyProductQuota: json['daily_product_quota'] as int,
    );
  }

  User toDomain() {
    return User(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      dailyProductQuota: dailyProductQuota ?? 9999,
    );
  }
}
