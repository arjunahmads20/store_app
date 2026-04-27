import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:store_app/src/features/product/presentation/widgets/discount_badge.dart';
import 'package:store_app/src/features/product/presentation/widgets/points_badge.dart';
import 'package:store_app/src/features/product/presentation/widgets/review_item.dart';
import 'package:store_app/src/features/cart/presentation/widgets/cart_badge.dart';
import 'package:store_app/src/features/review/presentation/product_review_list_screen.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/product/domain/review.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';
import 'package:store_app/src/features/product/data/flashsale_repository.dart';
import 'package:store_app/src/features/product/presentation/widgets/flashsale_countdown.dart';

// --- Providers ---

final productReviewsProvider = FutureProvider.family<List<Review>, Product>((
  ref,
  product,
) {
  return ref
      .watch(productRepositoryProvider)
      .getReviews(product.parentProductId, pageSize: 3);
});

final relatedProductsProvider = FutureProvider.family<List<Product>, Product>((
  ref,
  product,
) {
  return ref
      .watch(productRepositoryProvider)
      .getRelatedProducts(
        product.productCategoryId ?? 'All',
        product.parentProductId,
      );
});

final quantityProvider = StateProvider.autoDispose<int>((ref) => 1);

// --- Screen ---

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  void _toggleFavorite() async {
    final previousState = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    try {
      await ref
          .read(productRepositoryProvider)
          .toggleFavorite(widget.product.parentProductId, previousState);
    } catch (e) {
      if (mounted) setState(() => _isFavorite = previousState);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final reviewsAsync = ref.watch(productReviewsProvider(product));
    final relatedAsync = ref.watch(relatedProductsProvider(product));
    final quantity = ref.watch(quantityProvider);
    final activeFlashsalesAsync = ref.watch(activeFlashsalesProvider);

    final hasDiscount = product.sellPrice < product.buyPrice;
    final discountPercent = hasDiscount
        ? ((product.buyPrice - product.sellPrice) / product.buyPrice * 100)
              .round()
        : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar with Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black, // For back button
            flexibleSpace: FlexibleSpaceBar(
              background: product.pictureUrl != null
                  ? Image.network(product.pictureUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Share clicked (Placeholder)"),
                    ),
                  );
                },
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.share, color: Colors.black, size: 20),
                ),
              ),
              IconButton(
                onPressed: _toggleFavorite,
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const CartBadge(color: Colors.black),
              const SizedBox(width: 8),
            ],
          ),

          // 2. Product Info
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Price & Flashsale
                // Price & Flashsale
                if (product.isFlashSale)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9000), Color(0xFFFF5000)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "FLASH SALE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            activeFlashsalesAsync.when(
                              data: (flashsales) {
                                if (flashsales.isEmpty)
                                  return const SizedBox.shrink();
                                return FlashsaleCountdown(
                                  endTime: flashsales.first.endDateTime,
                                  textColor: Colors.white,
                                  color: Colors.white.withOpacity(0.2),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency(product.sellPrice),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (product.sellPrice < product.buyPrice)
                              Text(
                                formatCurrency(product.buyPrice),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (hasDiscount && discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-$discountPercent%',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (product.pointEarned > 0) ...[
                          const SizedBox(height: 8),
                          PointsBadge(
                            points: product.pointEarned,
                            fontSize: 12,
                            iconSize: 14,
                            isInverted: true,
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.sellPrice < product.buyPrice)
                                Text(
                                  formatCurrency(product.buyPrice),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              Text(
                                formatCurrency(product.sellPrice),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (hasDiscount)
                            DiscountBadge(
                              discountPercent: discountPercent,
                              isFlashSale: false,
                              fontSize: 12,
                            ),
                        ],
                      ),
                      if (product.pointEarned > 0) ...[
                        const SizedBox(height: 8),
                        PointsBadge(
                          points: product.pointEarned,
                          fontSize: 12,
                          iconSize: 14,
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 12),

                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Stats: Ratings, Sold
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${product.rating} (${product.reviewCount})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${product.soldCount} Sold",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                if (product.tags != null && product.tags!.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.tags!
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? "No description available.",
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Stock: ${product.stock}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 24),
                const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
                const SizedBox(height: 24),

                // Reviews
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Product Reviews (${product.reviewCount})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (product.reviewCount > 3)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductReviewListScreen(product: product),
                            ),
                          );
                        },
                        child: const Text("See All"),
                      ),
                  ],
                ),
                reviewsAsync.when(
                  data: (reviews) {
                    if (reviews.isEmpty)
                      return const Text(
                        "No reviews yet.",
                        style: TextStyle(color: Colors.grey),
                      );
                    return Column(
                      children: reviews
                          .take(3)
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ReviewItem(review: r),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Text("Failed to load reviews"),
                ),

                const SizedBox(height: 24),
                const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
                const SizedBox(height: 24),

                // Recommendations
                const Text(
                  "You May Also Like",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),

          // Horizontal List for Recommendations
          SliverToBoxAdapter(
            child: SizedBox(
              height: 290,
              child: relatedAsync.when(
                data: (products) {
                  if (products.isEmpty)
                    return const Center(child: Text("No recommendations"));
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return ProductCard(product: p);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ), // Bottom padding
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Control
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () => ref.read(quantityProvider.notifier).state--
                          : null,
                      icon: const Icon(Icons.remove, size: 20),
                      color: quantity > 1 ? Colors.black : Colors.grey,
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        "$quantity",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(quantityProvider.notifier).state++,
                      icon: const Icon(Icons.add, size: 20),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Add to Cart Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = ref.read(authControllerProvider).value;
                      if (user == null) {
                        context.go('/login');
                        return;
                      }

                      if (product.stock <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Out of Stock')),
                        );
                        return;
                      }

                      final success = await ref
                          .read(cartControllerProvider.notifier)
                          .addToCart(
                            product.parentProductId,
                            quantity,
                          ); // 2 Be careful here, because addToCart requires the global product id not the id for ProductInStore instance
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} added to cart ($quantity)',
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          final error = ref.read(cartControllerProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add to cart: ${error ?? "Unknown error"}',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          ref.read(cartControllerProvider.notifier).refresh();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
