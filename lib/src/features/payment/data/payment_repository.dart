import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';

import 'package:store_app/src/features/payment/domain/payment_method.dart';

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _dio.get(ApiConstants.paymentMethods);
      final results = response.data['results'] as List;
      return results.map((e) => PaymentMethod.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load payment methods: $e');
    }
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepository(dio);
});
