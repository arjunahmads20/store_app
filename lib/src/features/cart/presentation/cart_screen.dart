import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;
    final recommendedProductsValue = ref.watch(recommendedProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: cartState.when(
          data: (cart) {
            if (cart == null || cart.items.isEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your cart is empty",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 48),

                    // Recommended Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You might also like',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          recommendedProductsValue.when(
                            data: (products) => GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.60,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) =>
                                  ProductCard(product: products[index]),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, s) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Daily Quota Info (Mock for now or derive from User)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You have used ${cart.totalItems}/${user?.dailyProductQuota ?? 999} daily product quota.",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                // Cart Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartItemWidget(item: item);
                    },
                  ),
                ),
                // Checkout Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              formatCurrency(cart.totalCost),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                          ),
                          child: const Text("Checkout"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _CartItemWidget extends ConsumerWidget {
  final CartItem item;

  const _CartItemWidget({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            activeColor: AppColors.primary,
            onChanged: (val) {
              ref
                  .read(cartControllerProvider.notifier)
                  .toggleCheck(item.id, val ?? false);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push(
                  '/product/${item.product.id}',
                  extra: item.product,
                );
              },
              behavior: HitTestBehavior
                  .opaque, // Ensure clicks on empty space in row are caught
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.product.pictureUrl != null
                          ? Image.network(
                              item.product.pictureUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        // Category/Variant & Size/Unit Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.categoryName ??
                                        item.product.productCategoryId ??
                                        'General',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  if (item.product.size != null &&
                                      item.product.unit != null)
                                    Text(
                                      "${item.product.size} ${item.product.unit}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                ref
                                    .read(cartControllerProvider.notifier)
                                    .removeItem(item.id);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Discount Info
                        if (item.product.discountPercentage != null &&
                            item.product.discountPercentage! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.product.isFlashSale
                                        ? Colors.orange
                                        : Colors.red.shade50,
                                    gradient: item.product.isFlashSale
                                        ? const LinearGradient(
                                            colors: [
                                              Colors.orange,
                                              Colors.redAccent,
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (item.product.isFlashSale)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 2.0),
                                          child: Icon(
                                            Icons.flash_on,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      Text(
                                        "${item.product.discountPercentage!.toStringAsFixed(0)}% OFF",
                                        style: TextStyle(
                                          color: item.product.isFlashSale
                                              ? Colors.white
                                              : Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (item.product.buyPrice >
                                    item.product.sellPrice)
                                  Text(
                                    formatCurrency(item.product.buyPrice),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatCurrency(item.product.sellPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                // Line Total
                                Text(
                                  "Total: ${formatCurrency(item.product.sellPrice * item.quantity)}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            // Qty Control
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (item.quantity > 1) {
                                        ref
                                            .read(
                                              cartControllerProvider.notifier,
                                            )
                                            .updateQuantity(
                                              item.id,
                                              item.quantity - 1,
                                            );
                                      } else {
                                        // Maybe ask confirmation before delete?
                                        ref
                                            .read(
                                              cartControllerProvider.notifier,
                                            )
                                            .removeItem(item.id);
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  Text(
                                    "${item.quantity}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ref
                                          .read(cartControllerProvider.notifier)
                                          .updateQuantity(
                                            item.id,
                                            item.quantity + 1,
                                          );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Icon(Icons.add, size: 16),
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
