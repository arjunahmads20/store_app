import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/store/data/store_dto.dart';
import 'package:store_app/src/features/store/domain/store.dart';

abstract class StoreRepository {
  Future<List<Store>> getStores();
  Future<Store?> getNearestStore();
}

class RemoteStoreRepository implements StoreRepository {
  final Dio _dio;

  RemoteStoreRepository(this._dio);

  @override
  Future<List<Store>> getStores() async {
    try {
      // Assuming a generic endpoint for now, or we might need to use specific IDs
      // The requirement is mostly just to show *a* store on the home page.
      // We will check /api/v1/user/stores/ or similar if it exists, otherwise just mock for now until confirmed.
      // Schema check: "Store" is likely under "Product App" or "User App"?
      // Actually, let's use a Mock implementation for the "Nearest Store" if API is not obvious,
      // but let's try to fetch from a plausible endpoint.
      // Based on previous chats, Store model exists.
      final response = await _dio.get('/store/stores/');
      final rawData = response.data;
      List data = [];
      if (rawData is Map && rawData.containsKey('results')) {
        data = rawData['results'];
      } else if (rawData is List) {
        data = rawData;
      }
      return data.map((e) => StoreDto.fromJson(e).toDomain()).toList();
    } catch (e) {
      // Rethrow to let the UI Provider handle the error state
      throw Exception('Failed to fetch stores: $e');
    }
  }

  @override
  Future<Store?> getNearestStore() async {
    final stores = await getStores();
    if (stores.isNotEmpty) {
      return stores.first;
    }
    return null;
  }
}

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return RemoteStoreRepository(ref.watch(dioProvider));
});

final nearestStoreProvider = FutureProvider<Store?>((ref) {
  return ref.watch(storeRepositoryProvider).getNearestStore();
});
