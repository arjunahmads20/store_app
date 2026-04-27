import 'package:equatable/equatable.dart';

class ProductInOrderReview extends Equatable {
  final int id;
  final int productInOrderId; // ID of the ProductInOrder
  final int rate;
  final String comment;

  const ProductInOrderReview({
    required this.id,
    required this.productInOrderId,
    required this.rate,
    required this.comment,
  });

  factory ProductInOrderReview.fromJson(Map<String, dynamic> json) {
    return ProductInOrderReview(
      id: json['id'] as int,
      productInOrderId: json['product_in_order'] as int,
      rate: json['rate'] as int,
      comment: json['comment'] as String,
    );
  }

  @override
  List<Object?> get props => [id, productInOrderId, rate, comment];
}
