import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/product/data/flashsale_dto.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/domain/flashsale.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/store/data/store_repository.dart';

abstract class FlashsaleRepository {
  Future<List<Flashsale>> getFlashsales();
  Future<List<Product>> getFlashsaleProducts(String flashsaleId);
}

class RemoteFlashsaleRepository implements FlashsaleRepository {
  final Dio _dio;
  final ProductRepository _productRepository;

  RemoteFlashsaleRepository(this._dio, this._productRepository);

  @override
  Future<List<Flashsale>> getFlashsales() async {
    try {
      final response = await _dio.get('/product/flashsales/');
      final data = response.data;
      List list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list
          .map((json) => FlashsaleDto.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch flashsales: $e');
    }
  }

  @override
  Future<List<Product>> getFlashsaleProducts(String flashsaleId) async {
    try {
      final store = await RemoteStoreRepository(this._dio).getNearestStore();
      final storeId = store?.id;
      // 1. Get items in flashsale (which are store agnostic)
      final response = await _dio.get(
        '/product/product-in-store-in-flashsales/',
        queryParameters: {'flashsale': flashsaleId, 'store': storeId},
      );
      final data = response.data;
      List items;
      if (data is Map && data.containsKey('results')) {
        items = data['results'];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      // 2. Fetch full product details for each item
      // The item has "product" ID.
      List<Product> products = [];
      for (var item in items) {
        final productId =
            item['product_id']; // This is the global product ID, not the ProductInStore ID
        if (productId != null) {
          final product = await _productRepository.getProduct(
            productId.toString(),
          );
          if (product != null) {
            // Optionally override price/discount with flashsale specific info if needed
            // But ProductDto already parses flashsale_info if present in /product-in-stores/
            // However, detailed flashsale item info (stock limit etc) is here in `item`.
            // For now, let's just return the product.
            products.add(product);
          }
        }
      }
      return products;
    } catch (e) {
      throw Exception('Failed to fetch flashsale products: $e');
    }
  }
}

final flashsaleRepositoryProvider = Provider<FlashsaleRepository>((ref) {
  return RemoteFlashsaleRepository(
    ref.watch(dioProvider),
    ref.watch(productRepositoryProvider),
  );
});

final activeFlashsalesProvider = FutureProvider<List<Flashsale>>((ref) async {
  final flashsales = await ref
      .watch(flashsaleRepositoryProvider)
      .getFlashsales();
  return flashsales.where((fs) => fs.isActive).toList();
});
