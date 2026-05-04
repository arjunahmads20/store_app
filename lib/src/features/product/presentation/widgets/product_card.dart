import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/product/presentation/widgets/discount_badge.dart';
import 'package:store_app/src/features/product/presentation/widgets/points_badge.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';
import 'package:transparent_image/transparent_image.dart';
                     

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate Discount %
    final hasDiscount =
        product.sellPrice <
        product.buyPrice; // Using buyPrice as 'original price' for mock
    final discountPercent = hasDiscount
        ? ((product.buyPrice - product.sellPrice) / product.buyPrice * 100)
              .round()
        : 0;

    return GestureDetector(
      onTap:
          onTap ??
          () {
            context.push(
              '/product/${product.parentProductId}',
              extra: product,
            ); // 3 Be careful here, this requires the global product id not the id for ProductInStore instance
          },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: product.pictureUrl != null
                            
                          ? FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: product.pictureUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey.shade300,
                                  ),
                                );
                              },
                            )
                      
                          : Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey.shade300,
                              ),
                            ),
                    ),
                  ),
                  // Badges (Discount & Points)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasDiscount)
                          if (hasDiscount)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: DiscountBadge(
                                discountPercent: discountPercent,
                                isFlashSale: product.isFlashSale,
                              ),
                            ),

                        // Points Badge
                        if (product.pointEarned > 0)
                          PointsBadge(points: product.pointEarned),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    product.categoryName ??
                        product.productCategoryId ??
                        'General',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Tags
                  if (product.tags != null && product.tags!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: product.tags!
                            .take(2)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 9,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                  // Rating Row
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating > 0 ? product.rating.toString() : 'N/A',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price & Add Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              formatCurrency(product.buyPrice),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10,
                                  ),
                            ),
                          Text(
                            formatCurrency(product.sellPrice),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Add Button / Quantity Control
                      Align(
                        alignment: Alignment.centerRight,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final cartValue = ref.watch(cartControllerProvider);
                            // Treat error as null (empty cart) to prevent stale state
                            final cart = (cartValue.hasError)
                                ? null
                                : cartValue.value;

                            // Find item in cart
                            final cartItem = cart?.items
                                .cast<CartItem?>()
                                .firstWhere(
                                  (item) => item?.product.id == product.id,
                                  orElse: () => null,
                                );

                            if (cartItem != null && cartItem.quantity > 0) {
                              // Quantity Control
                              return Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Decrease
                                    GestureDetector(
                                      onTap: () {
                                        if (cartItem.quantity > 1) {
                                          ref
                                              .read(
                                                cartControllerProvider.notifier,
                                              )
                                              .updateQuantity(
                                                cartItem.id,
                                                cartItem.quantity - 1,
                                              );
                                        } else {
                                          ref
                                              .read(
                                                cartControllerProvider.notifier,
                                              )
                                              .removeItem(cartItem.id);
                                        }
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 32,
                                        color: Colors.transparent, // Hit area
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    // Qty
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        '${cartItem.quantity}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    // Increase
                                    GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(
                                              cartControllerProvider.notifier,
                                            )
                                            .updateQuantity(
                                              cartItem.id,
                                              cartItem.quantity + 1,
                                            );
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 32,
                                        color: Colors.transparent,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: () async {
                                final user = ref
                                    .read(authControllerProvider)
                                    .value;
                                if (user == null) {
                                  context.go('/login'); // Redirect to Login
                                  return;
                                }

                                if (product.stock <= 0) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Out of Stock'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                final success = await ref
                                    .read(cartControllerProvider.notifier)
                                    .addToCart(
                                      product.parentProductId,
                                      1,
                                    ); // Be careful here, because addToCart requires the global product id not the id for ProductInStore instance
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.name} added to cart',
                                        ),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    final error = ref
                                        .read(cartControllerProvider)
                                        .error;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to add to cart: ${error ?? "Unknown error"}',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    ref
                                        .read(cartControllerProvider.notifier)
                                        .refresh(); // enable it if autoDispose is off
                                  }
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
