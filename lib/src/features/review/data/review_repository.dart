import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/review/domain/order_review.dart';
import 'package:store_app/src/features/review/domain/product_review.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  Future<void> submitOrderReview(int orderId, int rate, String comment) async {
    try {
      await _dio.post(
        '/order/order-reviews/',
        data: {'order': orderId, 'rate': rate, 'comment': comment},
      );
    } catch (e) {
      throw Exception('Failed to submit order review: $e');
    }
  }

  Future<void> submitProductReview(
    int productInOrderId,
    int rate,
    String comment,
  ) async {
    try {
      await _dio.post(
        '/order/product-in-order-reviews/',
        data: {
          'product_in_order': productInOrderId,
          'rate': rate,
          'comment': comment,
        },
      );
    } catch (e) {
      throw Exception('Failed to submit product review: $e');
    }
  }

  Future<OrderReview?> getOrderReview(int orderId) async {
    try {
      final response = await _dio.get(
        '/order/order-reviews/',
        queryParameters: {'order': orderId},
      );
      final data = response.data;
      List list = (data is Map && data.containsKey('results'))
          ? data['results']
          : (data is List ? data : []);
      return OrderReview.fromJson(list.first);
    } catch (e) {
      return null;
    }
  }

  Future<ProductInOrderReview?> getProductReview(int productInOrderId) async {
    try {
      final response = await _dio.get(
        '/order/product-in-order-reviews/',
        queryParameters: {'product_in_order': productInOrderId},
      );
      final data = response.data;
      List list = (data is Map && data.containsKey('results'))
          ? data['results']
          : (data is List ? data : []);
      return ProductInOrderReview.fromJson(list.first);
    } catch (e) {
      return null;
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(dioProvider));
});
