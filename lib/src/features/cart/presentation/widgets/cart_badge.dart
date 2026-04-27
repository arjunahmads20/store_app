import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class CartBadge extends ConsumerWidget {
  final Color? color;
  final double size;

  const CartBadge({super.key, this.color, this.size = 24.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartValue = ref.watch(cartControllerProvider);

    final int itemCount = cartValue.maybeWhen(
      data: (cart) =>
          (cart?.items ?? []).fold<int>(0, (sum, item) => sum + item.quantity),
      orElse: () => 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: Icon(Icons.shopping_cart_outlined, color: color, size: size),
        ),
        if (itemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
