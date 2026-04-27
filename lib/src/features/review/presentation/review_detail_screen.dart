import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/order/domain/order.dart';
import 'package:store_app/src/features/review/domain/order_review.dart';
import 'package:store_app/src/features/review/domain/product_review.dart';
import 'package:store_app/src/features/review/presentation/order_review_controller.dart';

class ReviewDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const ReviewDetailScreen({super.key, required this.order});

  @override
  ConsumerState<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends ConsumerState<ReviewDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reviews on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productIds = widget.order.products.map((e) => e.id).toList();
      ref
          .read(orderReviewControllerProvider.notifier)
          .fetchReviews(widget.order.id, productIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderReviewControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Details')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Order Review Section
                    const Text(
                      "Order Review",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.existingOrderReview != null)
                      _buildOrderReviewCard(state.existingOrderReview!)
                    else
                      const Text("No order review found."),

                    const SizedBox(height: 24),

                    // 2. Product Reviews Section
                    const Text(
                      "Product Reviews",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.existingProductReviews.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.order.products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final productInOrder = widget.order.products[index];
                          // Find review for this product
                          // Note: Depending on backend, we might have multiple, taking first or matching ID
                          try {
                            final review = state.existingProductReviews
                                .firstWhere(
                                  (r) =>
                                      r?.productInOrderId == productInOrder.id,
                                );
                            return _buildProductReviewCard(
                              review!,
                              productInOrder,
                            );
                          } catch (e) {
                            return const SizedBox.shrink(); // No review for this item?
                          }
                        },
                      )
                    else
                      const Text("No product reviews found."),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderReviewCard(OrderReview review) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingBarIndicator(
              rating: review.rate.toDouble(),
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 24.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 8),
            if (review.comment.isNotEmpty)
              Text(review.comment, style: const TextStyle(fontSize: 16)),
            if (review.comment.isEmpty)
              const Text(
                "No comment provided.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductReviewCard(
    ProductInOrderReview review,
    ProductInOrder productInOrder,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (productInOrder.product.pictureUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      productInOrder.product.pictureUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    productInOrder.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            RatingBarIndicator(
              rating: review.rate.toDouble(),
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 20.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 8),
            if (review.comment.isNotEmpty) Text(review.comment),
            if (review.comment.isEmpty)
              const Text(
                "No comment provided.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
