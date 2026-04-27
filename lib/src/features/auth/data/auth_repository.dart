import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/auth/domain/auth_repository.dart';
import 'package:store_app/src/features/auth/data/user_dto.dart';
import 'package:store_app/src/features/auth/domain/user.dart';

import 'package:store_app/src/features/auth/data/token_storage.dart';

class RemoteAuthRepository implements AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  RemoteAuthRepository(this._dio, this._tokenStorage);

  @override
  Stream<User?> get authStateChanges => Stream.value(null); // TODO: Implement persistence

  @override
  Future<User> login(String phoneNumber, String password) async {
    try {
      final response = await _dio.post(
        '/user/login/',
        data: {'phone_number': phoneNumber, 'password': password},
      );
      // Response format: { "token": "...", "user": { ... } }
      final data = response.data;
      final token = data['token'];
      final userMap = data['user'];

      print('Login Success. Token: $token');

      if (token != null) {
        await _tokenStorage.saveToken(token);
      }
      if (userMap != null) {
        await _tokenStorage.saveUser(userMap);
      }

      final userDto = UserDto.fromJson(userMap);
      return userDto.toDomain();
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        // Try to extract meaningful error message
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          throw Exception(data['detail']);
        } else if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Login failed. Please check your connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> requestRegistrationOtp({
    required String firstName,
    required String lastName,
    String? email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      await _dio.post(
        '/user/signup/request-otp/',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email ?? '',
          'password': password,
          'confirm_password': password,
          'phone_number': phoneNumber,
          'gender': gender,
          'date_of_birth': dateOfBirth,
        },
      );
    } on DioException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<User> verifyRegistration({
    required Map<String, dynamic> registrationData,
    required String otp,
  }) async {
    try {
      final dataToSend = Map<String, dynamic>.from(registrationData);
      dataToSend['otp'] = otp;

      final response = await _dio.post(
        '/user/signup/verify/',
        data: dataToSend,
      );

      final data = response.data;
      final token = data['token'];
      final userMap = data['user'];

      if (token != null) {
        await _tokenStorage.saveToken(token);

        try {
          // Fetch full user profile because UserRegistrationSerializer omits id and username
          final meResponse = await _dio.get('/user/users/me/');
          final fullUserMap = meResponse.data;
          if (fullUserMap != null) {
            await _tokenStorage.saveUser(fullUserMap);
            return UserDto.fromJson(fullUserMap).toDomain();
          }
        } catch (e) {
          print('Failed to fetch full profile after verify: $e');
        }
      }

      if (userMap != null) {
        // Fallback: patch missing fields if me request fails
        userMap['id'] ??= 0;
        userMap['username'] ??= userMap['phone_number'] ?? 'user';
        await _tokenStorage.saveUser(userMap);
      }

      final userDto = UserDto.fromJson(userMap ?? {});
      return userDto.toDomain();
    } on DioException catch (e) {
      _handleAuthError(e);
      throw Exception(
        'Verification failed',
      ); // Unreachable due to _handleAuthError throwing, but good for lint
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  void _handleAuthError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        final messages = data.values
            .map((v) => v is List ? v.join(', ') : v.toString())
            .join('\n');
        if (messages.isNotEmpty) throw Exception(messages);
        if (data.containsKey('detail')) throw Exception(data['detail']);
      }
    }
    throw Exception('Request failed. Please try again.');
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearAll();
  }

  @override
  Future<User?> restoreUser() async {
    final userMap = _tokenStorage.getUser();
    if (userMap != null) {
      try {
        final userDto = UserDto.fromJson(userMap);
        return userDto.toDomain();
      } catch (e) {
        // If parsing fails, clear bad data
        await _tokenStorage.clearAll();
        return null;
      }
    }
    return null;
  }

  @override
  Future<User> refreshUser() async {
    try {
      final response = await _dio.get('/user/users/me/');
      final userMap = response.data;
      if (userMap != null) {
        await _tokenStorage.saveUser(userMap);
        final userDto = UserDto.fromJson(userMap);
        return userDto.toDomain();
      }
      throw Exception('Failed to refresh user data');
    } on DioException catch (e) {
      _handleAuthError(e);
      throw Exception('Refresh failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? avatarPath, // Local path to upload, or handle separately?
    // For now, assuming multipart request if avatar is present
  }) async {
    try {
      final formData = FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (email != null) 'email': email,
        if (avatarPath != null)
          'avatar': await MultipartFile.fromFile(avatarPath),
      });

      final response = await _dio.patch(
        '/user/users/me/', // Assuming this endpoint
        data: formData,
      );

      final data = response.data;
      final userMap = data['user'] ?? data; // Depending on response structure

      if (userMap != null) {
        // Update local storage
        final currentUser = _tokenStorage.getUser();
        if (currentUser != null) {
          final updatedUser = {
            ...currentUser,
            ...Map<String, dynamic>.from(userMap),
          };
          await _tokenStorage.saveUser(updatedUser);
        } else {
          await _tokenStorage.saveUser(Map<String, dynamic>.from(userMap));
        }

        final userDto = UserDto.fromJson(userMap);
        return userDto.toDomain();
      }
      throw Exception("Failed to parse updated user data");
    } on DioException catch (e) {
      _handleAuthError(e);
      throw Exception('Update failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return RemoteAuthRepository(dio, tokenStorage);
});
