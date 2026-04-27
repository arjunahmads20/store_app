import 'user.dart';

abstract class AuthRepository {
  Future<User> login(String phoneNumber, String password);
  Future<void> requestRegistrationOtp({
    required String firstName,
    required String lastName,
    String? email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
  });

  Future<User> verifyRegistration({
    required Map<String, dynamic> registrationData,
    required String otp,
  });
  Future<void> logout();
  Future<User?> restoreUser();
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? avatarPath,
  });
  Future<User> refreshUser();

  Stream<dynamic> get authStateChanges;
}
