import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final int dailyProductQuota;

  final String username;

  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    required this.dailyProductQuota,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    firstName,
    lastName,
    email,
    phoneNumber,
    avatarUrl,
    dailyProductQuota,
  ];
}
