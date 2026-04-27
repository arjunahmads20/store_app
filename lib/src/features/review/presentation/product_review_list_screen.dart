import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/product/presentation/product_detail_screen.dart'; // Can reuse provider if not private, checking...
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/product/domain/review.dart';
import 'package:store_app/src/features/product/presentation/widgets/review_item.dart';
import 'package:store_app/src/features/review/presentation/product_reviews_controller.dart';

class ProductReviewListScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductReviewListScreen({super.key, required this.product});

  @override
  ConsumerState<ProductReviewListScreen> createState() =>
      _ProductReviewListScreenState();
}

class _ProductReviewListScreenState
    extends ConsumerState<ProductReviewListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(productReviewsControllerProvider(widget.product).notifier)
          .loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(
      productReviewsControllerProvider(widget.product),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Builder(
          builder: (context) {
            if (reviewsState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (reviewsState.reviews.isEmpty && !reviewsState.isLoading) {
              return const Center(child: Text("No reviews yet."));
            }
            if (reviewsState.error != null && reviewsState.reviews.isEmpty) {
              return Center(child: Text("Error: ${reviewsState.error}"));
            }

            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  reviewsState.reviews.length +
                  (reviewsState.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                if (index == reviewsState.reviews.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final review = reviewsState.reviews[index];
                return ReviewItem(review: review);
              },
            );
          },
        ),
      ),
    );
  }
}
