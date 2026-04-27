import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/product/data/product_dto.dart';
import 'package:store_app/src/features/product/domain/product.dart';

class CartDto {
  final int id;
  final int user;

  CartDto({required this.id, required this.user});

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(id: json['id'] as int, user: json['user'] as int);
  }

  Cart toDomain(List<CartItem> items) {
    return Cart(id: id, userId: user, items: items);
  }
}

class CartItemDto {
  final int id;
  final int userCart;
  final dynamic
  productData; // Can be int (ID) or Object (Comprehensive) depending on API depth
  final int quantity;
  final bool isChecked;

  CartItemDto({
    required this.id,
    required this.userCart,
    required this.productData,
    required this.quantity,
    required this.isChecked,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      id: json['id'] as int,
      userCart: json['user_cart'] as int,
      productData: json['product'], // Keep dynamic to handle ID vs Object
      quantity: json['quantity'] as int,
      isChecked: json['is_checked'] as bool? ?? true,
    );
  }

  // Helper to convert to domain if we have the product Details
  CartItem toDomain(Product product) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity,
      isChecked: isChecked,
    );
  }
}
