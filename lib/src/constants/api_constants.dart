import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store_app/src/features/auth/data/token_storage.dart';

class ApiConstants {
  static const String baseUrl = 'http://storeappxyz.pythonanywhere.com/api/v1'; // Be carefull to distinct http with https
  static const String products = '/product/products/';
  static const String orders = '/order/orders/';
  static const String deliveryTypes = '/order/delivery-types/';
  static const String paymentMethods = '/payment/payment-methods/';
  static const String cart = '/product/user-carts/';
  static const String userAddresses = '/address/user-addresses/';
  static const String voucherOrders = '/voucher/voucher-orders/';
  static const String userVoucherOrders = '/voucher/user-voucher-orders/';
  static const String userPointMembershipRewards = '/membership/user-point-membership-rewards/';
}

// Network Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://storeappxyz.pythonanywhere.com/api/v1', // Use 10.0.2.2 for Android Emulator if needed
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
    headers: {
      'Accept': 'application/json',
    },
  ));

  // Token Interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = tokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Token $token';
      }
      handler.next(options);
    },
  ));
  
  // Debug Interceptor
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  
  return dio;
});
