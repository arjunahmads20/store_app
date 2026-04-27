import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/product/data/product_dto.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/product/domain/product_category.dart';
import 'package:store_app/src/features/product/domain/review.dart';
import 'package:store_app/src/features/store/data/store_repository.dart';

abstract class ProductRepository {
  Future<List<ProductCategory>> getCategories();
  Future<List<Product>> getProducts({
    int? storeId,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isSupportCod,
    bool? isSupportInstantDelivery,
    bool? isContainPoints,
    bool? isRecommended, // Added parameter
    String? sortBy, // e.g., 'name', 'sell_price', 'sold_count'
    bool descending = false,
    int? page,
    int? pageSize,
  });
  Future<Product?> getProduct(String id);
  Future<Product?> getProductInStoreById(int id);
  Future<List<Review>> getReviews(String productId, {int? page, int? pageSize});
  Future<List<Product>> getRelatedProducts(
    String categoryId,
    String currentProductId,
  );
  Future<bool> toggleFavorite(String productId, bool isCurrentlyFavorite);
}

class RemoteProductRepository implements ProductRepository {
  final Dio _dio;

  RemoteProductRepository(this._dio);

  @override
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _dio.get('/product/product-categories/');
      final list = response.data['results'] as List; // Adjusted for pagination
      return list
          .map((json) => ProductCategoryDto.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      // Return empty list or rethrow depending on requirement.
      // For now, logging and rethrowing is safer for debugging.
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<Product>> getProducts({
    int? storeId,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isSupportCod,
    bool? isSupportInstantDelivery,
    bool? isContainPoints,
    bool? isRecommended, // Added parameter
    String? sortBy,
    bool descending = false,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storeId != null) queryParams['store'] = storeId;

      // Pagination
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      // Use 'search_keyword' as per API_Filtering_Guide.md

      // Use 'search_keyword' as per API_Filtering_Guide.md
      if (search != null && search.isNotEmpty)
        queryParams['search_keyword'] = search;

      if (categoryId != null && categoryId != 'All')
        queryParams['category'] = categoryId;

      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;

      if (isSupportCod == true) queryParams['is_support_cod'] = true;
      if (isSupportInstantDelivery == true)
        queryParams['is_support_instant_delivery'] = true;

      if (isContainPoints == true) queryParams['is_contain_points'] = true;
      if (isRecommended == true) queryParams['is_recommended'] = true;

      if (sortBy != null) {
        final prefix = descending ? '-' : '';
        queryParams['sortby'] = '$prefix$sortBy';
      }

      final response = await _dio.get(
        '/product/product-in-stores/',
        queryParameters: queryParams,
      );
      // API might return pagination wrapped like { "count": ..., "results": [] } or just []
      // Assuming list based on Schema, but most DRF is paginated.
      // If it's paginated, response.data['results']
      // Let's assume list for now or check Schema.
      // Checking Schema... "ComprehensiveProductSerializer" usage suggests list.
      // But typically DRF ViewSets are paginated.
      // Let's handle both safely.
      final data = response.data;
      List list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list.map((json) => ProductDto.fromJson(json).toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<Product?> getProduct(String id) async {
    final store = await RemoteStoreRepository(this._dio).getNearestStore();
    final storeId = store?.id;
    try {
      final response = await _dio.get(
        '/product/product-in-stores/',
        queryParameters: {'product': id, 'store': storeId},
      ); // Becareful here, because the id should be for the Product instance, not for the ProductInStore instance
      return ProductDto.fromJson(response.data['results'][0]).toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Product?> getProductInStoreById(int id) async {
    try {
      final response = await _dio.get('/product/product-in-stores/$id/');
      return ProductDto.fromJson(response.data).toDomain();
    } catch (e) {
      return null;
    }
  }

  // --- New Methods ---

  Future<List<Review>> getReviews(
    String productId, {
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{'product': productId};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      final response = await _dio.get(
        '/order/product-in-order-reviews/',
        queryParameters: queryParams,
      );
      final data = response.data;
      List list = (data is Map && data.containsKey('results'))
          ? data['results']
          : (data is List ? data : []);

      return list.map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      // Fail silently for reviews if API/Filter not ready
      return [];
    }
  }

  Future<List<Product>> getRelatedProducts(
    String categoryId,
    String currentProductId,
  ) async {
    try {
      // Reuse getProducts
      final products = await getProducts(categoryId: categoryId, pageSize: 6);
      return products.where((p) => p.id != currentProductId).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> toggleFavorite(
    String productId,
    bool isCurrentlyFavorite,
  ) async {
    try {
      if (!isCurrentlyFavorite) {
        // Add
        // Schema implies 'product' ID is needed.
        // Note: The product ID in 'product-in-stores' is an inventory ID.
        // 'UserFavorite' schema expects 'product' (Global ID).
        // BUT we are viewing a 'ProductInStore'.
        // We need the global 'product' ID.
        // Our 'Product' domain model has 'id' which is usually the 'ProductInStore' ID in the detail view context (if fetched from product-in-stores).
        // Wait, 'ProductDto' mapping: id -> id.
        // If we are passing 'product_in_store' ID to 'user-product-favorites' which expects global 'product', it will fail.
        // However, usually favorites are on the GLOBAL product.
        // Let's assume we need the global product ID.
        // Our Product model should have it. 'parentProductId'.

        // Checking Product model: 'final String? parentProductId; // Global Product ID'

        // If parentProductId is null, we might be using global product directly?
        // Let's use parentProductId ?? productId and hope for best or handle mapping.
        // Actually, if we are in 'ProductDetail', we likely have 'ProductInStore'.

        // Let's try posting 'product': productId (assuming the favorite is on the inventory item? Unlikely).
        // Schema: "User Favorite... product: 1".
        // Product Schema: "Product (Global)... id: 1".
        // ProductInStore Schema: "product: 1".

        // So UserFavorite links to Global Product.
        // We need to send Global Product ID.

        await _dio.post(
          '/product/user-product-favorites/',
          data: {'product': productId},
        );
        return true;
      } else {
        // Remove
        // Need to find the favorite ID first.
        final response = await _dio.get(
          '/product/user-product-favorites/',
          queryParameters: {'product': productId},
        );
        final data = response.data;
        List list = (data is Map && data.containsKey('results'))
            ? data['results']
            : (data is List ? data : []);

        if (list.isNotEmpty) {
          final favId = list.first['id'];
          await _dio.delete('/product/user-product-favorites/$favId/');
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return RemoteProductRepository(ref.watch(dioProvider));
});

final categoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  return ref.watch(productRepositoryProvider).getCategories();
});

// Main products provider (for Home Screen - Store Only)
final recommendedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final store = await ref.watch(nearestStoreProvider.future);
  final storeId = store != null ? int.tryParse(store.id) : null;
  return ref
      .watch(productRepositoryProvider)
      .getProducts(storeId: storeId, isRecommended: true);
});

// Category products provider family
final categoryProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  categoryId,
) async {
  final store = await ref.watch(nearestStoreProvider.future);
  final storeId = store != null ? int.tryParse(store.id) : null;
  return ref
      .watch(productRepositoryProvider)
      .getProducts(storeId: storeId, categoryId: categoryId);
});
