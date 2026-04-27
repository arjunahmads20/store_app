import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/order/domain/order.dart';
import 'package:store_app/src/features/review/presentation/order_review_controller.dart';

class ReviewOrderScreen extends ConsumerStatefulWidget {
  final Order order;

  const ReviewOrderScreen({super.key, required this.order});

  @override
  ConsumerState<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends ConsumerState<ReviewOrderScreen> {
  // Order Review State
  double _orderRating = 5.0;
  final _orderCommentController = TextEditingController();

  // Product Review State
  final Map<int, double> _productRatings = {};
  final Map<int, TextEditingController> _productComments = {};

  @override
  void initState() {
    super.initState();
    // Initialize product controllers
    for (var product in widget.order.products) {
      _productRatings[product.id] = 5.0;
      _productComments[product.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _orderCommentController.dispose();
    for (var controller in _productComments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderReviewControllerProvider);

    // Listen for success
    ref.listen(orderReviewControllerProvider, (previous, next) {
      if (next.isSubmitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        context.pop(); // Go back to Order Detail
      }
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Review Order',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Review Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How was your order?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _orderRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                        ),
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) =>
                            setState(() => _orderRating = rating),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderCommentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Write a review (optional)",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Product Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final productInOrder = widget.order.products[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: productInOrder.product.pictureUrl != null
                                  ? Image.network(
                                      productInOrder.product.pictureUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                productInOrder.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Rate this product:",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        RatingBar.builder(
                          initialRating:
                              _productRatings[productInOrder.id] ?? 5.0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 24,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                          ),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) => setState(
                            () => _productRatings[productInOrder.id] = rating,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _productComments[productInOrder.id],
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Review this product (optional)",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          final productReviews = <int, ReviewData>{};
                          for (var product in widget.order.products) {
                            productReviews[product.id] = ReviewData(
                              rate: (_productRatings[product.id] ?? 5.0)
                                  .toInt(),
                              comment: _productComments[product.id]?.text ?? "",
                            );
                          }

                          ref
                              .read(orderReviewControllerProvider.notifier)
                              .submitReview(
                                orderId: widget.order.id,
                                orderRate: _orderRating.toInt(),
                                orderComment: _orderCommentController.text,
                                productReviews: productReviews,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors
                        .primary, // Ensure this exists or use Colors.orange if needed, likely AppColors.primary
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Review",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
