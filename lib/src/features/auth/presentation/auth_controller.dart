import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/auth/data/auth_repository.dart';

import 'package:store_app/src/features/auth/domain/auth_repository.dart';
import 'package:store_app/src/features/auth/domain/user.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:store_app/src/features/wallet/data/wallet_repository.dart';
import 'package:store_app/src/features/address/data/address_repository.dart';
import 'package:store_app/src/features/order/presentation/order_controller.dart';
import 'package:store_app/src/features/order/presentation/checkout/checkout_controller.dart';
import 'package:store_app/src/features/voucher/data/voucher_repository.dart';
import 'package:store_app/src/constants/api_constants.dart';

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final authRepository = ref.watch(authRepositoryProvider);
    return authRepository.restoreUser();
  }

  Future<void> login(String phoneNumber, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.login(phoneNumber, password);

      // Invalidate to ensure fresh data for new user
      _invalidateUserProviders();

      return user;
    });
  }

  Future<void> registerRequestOtp({
    required String firstName,
    required String lastName,
    String? email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.requestRegistrationOtp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      // Success: State remains null (not logged in), but loading is done.
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyRegistration({
    required Map<String, dynamic> registrationData,
    required String otp,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      return authRepository.verifyRegistration(
        registrationData: registrationData,
        otp: otp,
      );
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout();

      _invalidateUserProviders();

      return null;
    });
  }

  void clearError() {
    if (state.hasError) {
      // If the user isn't logged in, reset to data(null).
      // If they were somehow logged in but had an error, we keep the previous data.
      state = AsyncValue.data(state.value);
    }
  }

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      return authRepository.refreshUser();
    });
  }

  void _invalidateUserProviders() {
    ref.invalidate(cartControllerProvider);
    ref.invalidate(userWalletProvider);
    ref.invalidate(userAddressesProvider);
    ref.invalidate(orderControllerProvider);
    ref.invalidate(userVouchersProvider);
    ref.invalidate(checkoutControllerProvider);
    ref.invalidate(dioProvider);
    // Add others as needed
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});
