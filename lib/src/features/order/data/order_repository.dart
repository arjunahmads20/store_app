import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/order/domain/delivery_type.dart';
import 'package:store_app/src/features/order/domain/order.dart';
import 'package:store_app/src/features/order/domain/order_request.dart';

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  Future<List<Order>> getOrders({
    int? page,
    int? pageSize,
    String? status,
    int? deliveryTypeId,
    int? paymentMethodId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;
      if (status != null && status != 'All')
        queryParams['status'] = status
            .toLowerCase(); // Ensure lowercase matching if API expects it
      if (deliveryTypeId != null) queryParams['delivery_type'] = deliveryTypeId;
      if (paymentMethodId != null)
        queryParams['payment_method'] = paymentMethodId;

      final response = await _dio.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      final data = response.data;
      List list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order> getOrder(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.orders}$id/');
      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  Future<List<DeliveryType>> getDeliveryTypes() async {
    try {
      final response = await _dio.get(ApiConstants.deliveryTypes);
      final data = response.data;
      List list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list.map((e) => DeliveryType.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load delivery types: $e');
    }
  }

  Future<Order> createOrder(OrderRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.orders,
        data: request.toJson(),
      );
      return Order.fromJson(response.data);
    } catch (e) {
      // Improve error handling to read backend message if available
      if (e is DioException && e.response?.data != null) {
        throw Exception('Failed to create order: ${e.response?.data}');
      }
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> cancelOrder(int id) async {
    try {
      await _dio.post('${ApiConstants.orders}$id/cancel/');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception('Failed to cancel order: ${e.response?.data}');
      }
      throw Exception('Failed to cancel order: $e');
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRepository(dio);
});
