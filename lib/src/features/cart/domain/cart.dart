import 'package:equatable/equatable.dart';
import 'package:store_app/src/features/product/domain/product.dart';

class Cart extends Equatable {
  final int id;
  final int userId;
  final List<CartItem> items;

  const Cart({required this.id, required this.userId, this.items = const []});

  /// Total cost of checked items
  double get totalCost => items
      .where((item) => item.isChecked)
      .fold(0, (sum, item) => sum + (item.product.sellPrice * item.quantity));

  /// Total items count (sum of quantities)
  int get totalItems => items
      .where((item) => item.isChecked)
      .fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [id, userId, items];

  Cart copyWith({int? id, int? userId, List<CartItem>? items}) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }
}

class CartItem extends Equatable {
  final int id;
  final Product product;
  final int quantity;
  final bool isChecked;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.isChecked = true,
  });

  @override
  List<Object?> get props => [id, product, quantity, isChecked];

  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
    bool? isChecked,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
