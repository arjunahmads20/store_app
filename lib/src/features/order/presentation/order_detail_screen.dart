import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';
import 'package:store_app/src/features/address/data/address_repository.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';
import 'package:store_app/src/features/order/data/order_repository.dart';
import 'package:store_app/src/features/order/domain/order.dart';
import 'package:store_app/src/features/order/presentation/order_controller.dart';
import 'package:store_app/src/features/review/data/review_repository.dart';
import 'package:store_app/src/features/review/domain/order_review.dart';
import 'package:store_app/src/features/review/presentation/review_detail_screen.dart';
import 'package:store_app/src/features/review/presentation/review_order_screen.dart';

// --- Providers ---

final orderDetailsProvider = FutureProvider.family.autoDispose<Order, int>((
  ref,
  id,
) {
  return ref.read(orderRepositoryProvider).getOrder(id);
});

final orderAddressProvider = FutureProvider.family
    .autoDispose<UserAddress, int>((ref, id) {
      return ref.read(addressRepositoryProvider).getAddress(id);
    });

final orderReviewProvider = FutureProvider.family
    .autoDispose<OrderReview?, int>((ref, orderId) {
      return ref.read(reviewRepositoryProvider).getOrderReview(orderId);
    });

// --- Screen ---

class OrderDetailScreen extends ConsumerWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Order Detail"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Review Button
          orderAsync.when(
            data: (order) {
              if (order.status.toLowerCase() == 'completed' ||
                  order.status.toLowerCase() == 'finished') {
                final reviewsAsync = ref.watch(orderReviewProvider(orderId));
                return reviewsAsync.when(
                  data: (reviews) {
                    if (reviews != null) {
                      return TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewDetailScreen(order: order),
                            ),
                          );
                        },
                        child: const Text("View Review"),
                      );
                    } else {
                      return TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewOrderScreen(order: order),
                            ),
                          );
                          // Refresh reviews after returning
                          ref.refresh(orderReviewProvider(orderId));
                        },
                        child: const Text("Review"),
                      );
                    }
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Information
                _buildSection(
                  children: [
                    _buildInfoRow("Order ID", "#${order.id}"),
                    _buildInfoRow(
                      "Status",
                      order.status.toUpperCase(),
                      ishighlight: true,
                    ),
                    _buildInfoRow(
                      "Date Created",
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(order.datetimeCreated),
                    ),
                    // Placeholder for Date Finished
                    if (order.status.toLowerCase() == 'completed')
                      _buildInfoRow(
                        "Date Finished",
                        DateFormat('dd MMM yyyy, HH:mm').format(
                          order.datetimeCreated.add(const Duration(days: 3)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Status Roadmap
                _buildSection(
                  title: "Order Status",
                  children: [_StatusRoadmap(order: order)],
                ),
                const SizedBox(height: 16),

                // 3. Address
                _buildSection(
                  title: "Shipping Address",
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final addressAsync = ref.watch(
                          orderAddressProvider(order.addressId),
                        );
                        return addressAsync.when(
                          data: (address) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address.receiverName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(address.receiverPhoneNumber),
                              const SizedBox(height: 4),
                              Text(address.fullAddress),
                              // If we had full region names, we'd display them.
                            ],
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => const Text("Failed to load address"),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Delivery Type
                _buildSection(
                  title: "Delivery Method",
                  children: [
                    if (order.deliveryType != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.deliveryType!.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(formatCurrency(order.deliveryType!.cost)),
                        ],
                      )
                    else
                      const Text("Standard Delivery"),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Products
                Text(
                  "Products",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _OrderProductCard(item: order.products[index]),
                ),
                const SizedBox(height: 16),

                // 6. Voucher & Payment
                _buildSection(
                  children: [
                    if (order.voucher != null)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.voucher!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${order.voucher!.discountPercentage.toStringAsFixed(0)}% Off",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildInfoRow("Voucher", "No Voucher Used"),
                    const Divider(),
                    _buildInfoRow(
                      "Payment Method",
                      order.paymentInfo?.paymentMethod?.name ?? "Bank Transfer",
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/orders/${order.id}/payment-detail');
                        },
                        child: const Text("View Payment Details"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. Message for Driver
                if (order.messageForDriver != null &&
                    order.messageForDriver!.isNotEmpty)
                  _buildSection(
                    title: "Message for Driver",
                    children: [
                      Text(
                        order.messageForDriver!,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                if (order.messageForDriver != null &&
                    order.messageForDriver!.isNotEmpty)
                  const SizedBox(height: 16),

                // 8. Cost Breakdown
                Builder(
                  builder: (context) {
                    final double subtotal = order.totalProductCost;
                    final double delivery = order.deliveryType?.cost ?? 0;
                    final double admin =
                        order.paymentInfo?.paymentMethod?.discountedFee ?? 0;
                    final double discount =
                        (subtotal + delivery + admin) - order.totalCost;

                    return _buildSection(
                      title: "Cost Summary",
                      children: [
                        _buildCostRow("Subtotal for products", subtotal),
                        _buildCostRow("Delivery Cost", delivery),
                        _buildCostRow("Admin Fee", admin), // Or "Admin Cost"
                        if (discount > 0.01)
                          _buildCostRow(
                            "Voucher Discount",
                            -discount,
                            isDiscount: true,
                          ),
                        const Divider(height: 24),
                        _buildCostRow(
                          "Total Payment",
                          order.totalCost,
                          isTotal: true,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 9. Actions
                if (order.status.toLowerCase() == 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Cancel Order"),
                            content: const Text(
                              "Are you sure you want to cancel this order?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context); // Close dialog
                                  try {
                                    await ref
                                        .read(orderControllerProvider.notifier)
                                        .cancelOrder(order.id);
                                    // Refresh this detail page
                                    ref.refresh(orderDetailsProvider(order.id));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Order cancelled successfully",
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to cancel order: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  "Yes, Cancel",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Cancel Order"),
                    ),
                  ),

                if (order.status.toLowerCase() == 'shipped')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Confirm Received Logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Confirm Received Triggered"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Confirm Order Received"),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({String? title, required List<Widget> children}) {
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
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool ishighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ishighlight ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount
                  ? Colors.green
                  : (isTotal ? AppColors.primary : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRoadmap extends StatelessWidget {
  final Order order;

  const _StatusRoadmap({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    // Simple mock steps
    final steps = ["Pending", "Processed", "Shipped", "Completed"];
    int currentIndex = -1;

    final lowerStatus = status.trim().toLowerCase();
    if (lowerStatus == 'pending') currentIndex = 0;
    if (lowerStatus == 'processing' || lowerStatus == 'processed')
      currentIndex = 1;
    if (lowerStatus == 'shipped') currentIndex = 2;
    if (lowerStatus == 'completed' || lowerStatus == 'finished')
      currentIndex = 3;
    if (lowerStatus == 'cancelled') currentIndex = -1; // Handle differently?
    
    DateTime? getDateForStep(int index) {
      DateTime dt;
      switch (index) {
        case 0: dt = order.datetimeCreated; break;
        case 1: dt = order.datetimeProcessed; break;
        case 2: dt = order.datetimeShipped; break;
        case 3: dt = order.datetimeFinished; break;
        default: return null;
      }
      if (dt.year == 1970) return null;
      return dt;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final stepDate = getDateForStep(index);

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    border: isCurrent
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 4,
                          )
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: index < currentIndex
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  steps[index],
                  style: TextStyle(
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
                if (isCompleted)
                  Text(
                    stepDate != null 
                        ? DateFormat('yyyy-MM-dd HH:mm').format(stepDate) 
                        : "-",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _OrderProductCard extends StatelessWidget {
  final ProductInOrder item;

  const _OrderProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final double flashsaleDiscount = item.flashsaleDiscountPercentage;
    final double productDiscount = item.productDiscountPercentage;
    final double effectiveDiscount = flashsaleDiscount > productDiscount
        ? flashsaleDiscount
        : productDiscount;
    final bool hasDiscount = effectiveDiscount > 0;

    final double basePrice = item.product.sellPrice;
    final double discountedPrice = basePrice * (1 - effectiveDiscount / 100);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
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
                  ? Image.network(item.product.pictureUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges Row
                if (hasDiscount || item.pointEarned > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: flashsaleDiscount > 0
                                  ? Colors.orange
                                  : AppColors.error,
                              gradient: flashsaleDiscount > 0
                                  ? const LinearGradient(
                                      colors: [Colors.orange, Colors.redAccent],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (flashsaleDiscount > 0)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.flash_on,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                Text(
                                  "${effectiveDiscount.toStringAsFixed(0)}% OFF",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.pointEarned > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
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
                                  size: 10,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "+${item.pointEarned} Pts",
                                  style: TextStyle(
                                    color: Colors.amber.shade900,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                // Name
                Text(
                  item.product.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Specs
                Text(
                  "${item.product.size ?? '-'} ${item.product.unit ?? ''}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Price & Qty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              formatCurrency(basePrice),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                            ),
                          ),
                        Text(
                          formatCurrency(discountedPrice),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      "x${item.quantity}",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
