import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';

class VoucherRepository {
  final Dio _dio;

  VoucherRepository(this._dio);

  Future<List<UserVoucherOrder>> getUserVouchers({
    bool isUsed = false,
    bool? isExpired,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.userVoucherOrders,
        queryParameters: {
          'is_used': isUsed,
          'is_expired': isExpired,
          'page': page,
          'page_size': pageSize,
        },
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
      return list.map((e) => UserVoucherOrder.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load vouchers: $e');
    }
  }

  Future<List<VoucherOrder>> getVoucherOrders({
    String? sourceType,
    bool isClaimed = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.voucherOrders,
        queryParameters: {
          'source_type': sourceType,
          'is_claimed': isClaimed,
          'page': page,
          'page_size': pageSize,
        },
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
      return list.map((e) => VoucherOrder.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load voucher orders: $e');
    }
  }

  Future<void> claimVoucherOrder({int? voucherOrderId, String? code}) async {
    try {
      final data = <String, dynamic>{};
      if (voucherOrderId != null) data['voucher_order_id'] = voucherOrderId;
      if (code != null) data['code'] = code;

      await _dio.post(ApiConstants.userVoucherOrders, data: data);
    } catch (e) {
      // Handle known errors (e.g., already claimed)
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception(
          "You have already claimed this voucher or it is unavailable.",
        );
      }
      throw Exception('Failed to claim voucher: $e');
    }
  }
}

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepository(ref.watch(dioProvider));
});

final userVouchersProvider = FutureProvider<List<UserVoucherOrder>>((
  ref,
) async {
  return ref.watch(voucherRepositoryProvider).getUserVouchers();
});
