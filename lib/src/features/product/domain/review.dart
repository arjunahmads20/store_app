class Review {
  final int id;
  final int productInOrder; // Reference to the purchase
  final int rate;
  final String comment;
  // User info might not be directly available in the basic schema for 'ProductInOrderReview',
  // but typically reviews show user name.
  // The schema showed: { "id": 20, "product_in_order": 500, "rate": 4, "comment": "Good product." }
  // We might lack user info unless expanded. for now we'll use a placeholder or check if 'product_in_order' expands.

  Review({
    required this.id,
    required this.productInOrder,
    required this.rate,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productInOrder: json['product_in_order'],
      rate: json['rate'],
      comment: json['comment'] ?? '',
    );
  }
}
