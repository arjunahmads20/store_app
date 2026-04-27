import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';
import 'package:store_app/src/features/order/domain/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Status Color Logic - Uniform Grey
    const Color statusColor = Colors.grey;
    final Color statusBgColor = Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/orders/${order.id}', extra: order);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: statusBgColor,
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product Images Grid
                if (order.products.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: order.products.length > 4
                          ? 4
                          : order.products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final product = order.products[index].product;
                        return Container(
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            image: product.pictureUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(product.pictureUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.grey.shade100,
                          ),
                          child: product.pictureUrl == null
                              ? const Icon(
                                  Icons.image,
                                  size: 20,
                                  color: Colors.grey,
                                )
                              : (index == 3 && order.products.length > 4)
                              ? Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+${order.products.length - 3}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 12),

                // Footer: Price | Points (Aligned Right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Total Price",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          formatCurrency(order.totalCost),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (order.pointEarnedTotal > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        height: 24, // Separator height
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.amber.shade300,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "+${order.pointEarnedTotal} Pts",
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
