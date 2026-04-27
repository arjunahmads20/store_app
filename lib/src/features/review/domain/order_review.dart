import 'package:equatable/equatable.dart';

class OrderReview extends Equatable {
  final int id;
  final int orderId;
  final int rate;
  final String comment;

  const OrderReview({
    required this.id,
    required this.orderId,
    required this.rate,
    required this.comment,
  });

  factory OrderReview.fromJson(Map<String, dynamic> json) {
    return OrderReview(
      id: json['id'] as int,
      orderId: json['order'] as int,
      rate: json['rate'] as int,
      comment: json['comment'] as String,
    );
  }

  @override
  List<Object?> get props => [id, orderId, rate, comment];
}
