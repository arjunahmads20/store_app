import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/product/data/flashsale_repository.dart';
import 'package:store_app/src/features/product/domain/flashsale.dart';
import 'package:store_app/src/features/product/presentation/flashsale_screen.dart'; // For provider
import 'package:store_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:store_app/src/features/product/presentation/widgets/flashsale_countdown.dart';

class HomeFlashsaleSection extends ConsumerWidget {
  const HomeFlashsaleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashsalesValue = ref.watch(activeFlashsalesProvider);

    return flashsalesValue.when(
      data: (flashsales) {
        if (flashsales.isEmpty) return const SizedBox.shrink();

        // Get the ending soonest or first active
        final activeFlashsale = flashsales.first;

        return _FlashsaleContent(flashsale: activeFlashsale);
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }
}

class _FlashsaleContent extends ConsumerWidget {
  final Flashsale flashsale;
  const _FlashsaleContent({required this.flashsale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Consumer(
              builder: (context, ref, child) {
                final productsValue = ref.watch(
                  flashsaleProductsProvider(flashsale.id),
                );
                return productsValue.when(
                  data: (products) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        ProductCard(product: products[index]),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          context.push('/flashsale');
        },
        child: Row(
          children: [
            const Icon(
              Icons.flash_on_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flash Sale',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
                Text(
                  flashsale.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FlashsaleCountdown(
              endTime: flashsale.endDateTime,
              color: Colors.red.shade50,
              textColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}
