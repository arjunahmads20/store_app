import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/cart/data/cart_dto.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/store/domain/store.dart';
import 'package:store_app/src/features/store/data/store_repository.dart';

abstract class CartRepository {
  Future<Cart?> getCart({bool? isChecked});
  Future<Cart> createCart();
  Future<void> addToCart(int cartId, String productId, int quantity);
  Future<void> updateCartItem(
    int cartId,
    int itemId, {
    int? quantity,
    bool? isChecked,
  });
  Future<void> removeFromCart(int cartId, int itemId);
  Future<void> checkout(int cartId);
}

class RemoteCartRepository implements CartRepository {
  final Dio _dio;
  final ProductRepository _productRepository;

  RemoteCartRepository(this._dio, this._productRepository);

  @override
  Future<Cart?> getCart({bool? isChecked}) async {
    try {
      // 1. Get User's Cart
      final response = await _dio.get('/product/user-carts/');
      final rawData = response.data;

      print('GetCart Raw Data: $rawData'); // Debugging

      List data = [];
      if (rawData is Map && rawData.containsKey('results')) {
        data = rawData['results'];
      } else if (rawData is List) {
        data = rawData;
      }

      if (data.isEmpty) return null; // No cart found

      // Filter for active cart if possible, or take the last one created
      // Assuming the API returns a list, potentially sorted.
      // We'll take the first one for now but log if there are multiple.
      if (data.length > 1) {
        print('Warning: User has multiple carts: ${data.length}');
      }

      // Strategy: Use the first one.
      // If we had an 'is_active' field, we would filter:
      // final activeCart = data.firstWhere((c) => c['is_active'] == true, orElse: () => data[0]);
      final cartJson = data[0];

      final cartDto = CartDto.fromJson(cartJson);

      // 2. Get Cart Items
      final queryParams = <String, dynamic>{};
      if (isChecked != null) {
        queryParams['is_checked'] = isChecked;
      }
      final itemsResponse = await _dio.get(
        '/product/user-carts/${cartDto.id}/product-in-user-carts/',
        queryParameters: queryParams,
      );
      final rawItemsData = itemsResponse.data;
      List itemsData = [];
      if (rawItemsData is Map && rawItemsData.containsKey('results')) {
        itemsData = rawItemsData['results'];
      } else if (rawItemsData is List) {
        itemsData = rawItemsData;
      }

      // 3. Map Items and Fetch Product Details
      List<CartItem> domainItems = [];
      for (var itemJson in itemsData) {
        try {
          final itemDto = CartItemDto.fromJson(itemJson);

          final String productId = itemDto.productData.toString();

          final product = await _productRepository.getProduct(productId);

          if (product != null) {
            domainItems.add(itemDto.toDomain(product));
          }
        } catch (e) {
          print("Error mapping cart item: $itemJson, Error: $e");
        }
      }

      return cartDto.toDomain(domainItems);
    } catch (e) {
      print("GetCart Error: $e");
      throw Exception('Failed to fetch cart: $e');
    }
  }

  @override
  Future<Cart> createCart() async {
    try {
      final response = await _dio.post('/product/user-carts/', data: {});
      return CartDto.fromJson(response.data).toDomain([]);
    } catch (e) {
      throw Exception('Failed to create cart: $e');
    }
  }

  @override
  Future<void> addToCart(int cartId, String productId, int quantity) async {
    print(
      'RemoteCartRepository: addToCart called. Cart: $cartId, Product: $productId, Qty: $quantity',
    );
    final store = await RemoteStoreRepository(_dio).getNearestStore();
    final storeId = store?.id;
    try {
      await _dio.post(
        '/product/user-carts/$cartId/product-in-user-carts/',
        data: {
          'product': int.parse(productId),
          'quantity': quantity,
          'user_cart': cartId,
          'store_id': int.parse(storeId ?? '0'),
        },
      );
      print('RemoteCartRepository: addToCart success');
    } on DioException catch (e) {
      print(
        'RemoteCartRepository: addToCart failed. Status: ${e.response?.statusCode}, Data: ${e.response?.data}',
      );
      if (e.response?.statusCode == 403 || e.response?.statusCode == 400) {
        // Check specifically for ownership message
        final data = e.response?.data;
        if (data.toString().contains("You do not own this cart item")) {
          throw Exception("Cart sync error: Please refresh.");
        }
      }
      throw Exception('Failed to add to cart: ${e.message}');
    } catch (e) {
      print('RemoteCartRepository: addToCart failed: $e');
      throw Exception('Failed to add to cart: $e');
    }
  }

  @override
  Future<void> updateCartItem(
    int cartId,
    int itemId, {
    int? quantity,
    bool? isChecked,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (quantity != null) data['quantity'] = quantity;
      if (isChecked != null) data['is_checked'] = isChecked;

      if (data.isNotEmpty) {
        // Using nested endpoint as per architecture recommendation
        await _dio.patch(
          '/product/user-carts/$cartId/product-in-user-carts/$itemId/',
          data: data,
        );
      }
    } on DioException catch (e) {
      print(
        'UpdateCartItem Error: Status: ${e.response?.statusCode}, Data: ${e.response?.data}',
      );
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        // If 404, item might be gone. If 403, ownership issue.
        // We should ideally reload the cart.
        throw Exception("Item update failed. Please refresh your cart.");
      }
      throw Exception('Failed to update cart item: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  @override
  Future<void> removeFromCart(int cartId, int itemId) async {
    try {
      await _dio.delete(
        '/product/user-carts/$cartId/product-in-user-carts/$itemId/',
      );
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
    }
  }

  @override
  Future<void> checkout(int cartId) async {
    // This calls the validation/checkout endpoint or creates an order.
    // For now, let's assume it validates.
    try {
      // Endpoint structure: /app/resource/action/ -> /order/orders/checkout/
      await _dio.post(
        '/order/orders/checkout/',
        data: {'store_id': 1},
      ); // Placeholder store ID
    } catch (e) {
      throw Exception('Checkout failed: $e');
    }
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return RemoteCartRepository(
    ref.watch(dioProvider),
    ref.watch(productRepositoryProvider),
  );
});
