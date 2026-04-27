import 'package:flutter/material.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

class CheckoutProductCard extends StatelessWidget {
  final CartItem item;

  const CheckoutProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Assuming 'size' logic: usually products have variations.
    // Here we might verify if Product details support size unit similar to request.
    // user req: Name, Size (1), Unit (kg), Discount, Price, Discounted Price, Qty.
    // We map 'size' to quantity if 'unit' is 'kg' etc, or maybe Product has a 'size' attribute?
    // Let's assume quantity + unit for now.

    // Discount Logic Mockup:
    // If we have a stored discount, use it. For now, simulate or check props.
    // If not available, we show standard price.
    final hasDiscount = false; // Add logic if Product has distinct fields
    final double originalPrice =
        item.product.sellPrice * 1.2; // Mockup if needed, else just hide

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Picture
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.pictureUrl != null &&
                      item.product.pictureUrl!.isNotEmpty
                  ? item.product.pictureUrl!
                  : 'https://via.placeholder.com/64',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                width: 80,
                height: 80,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Size & Unit e.g. "1 kg"
                // Assuming item.product.unit exists (we'll check product.dart).
                // If not, we fall back to generic.
                if (item.product.unit != null && item.product.unit!.isNotEmpty)
                  Text(
                    "Size: 1 ${item.product.unit}", // This seems to be per-item size, not quantity.
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prices
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount) ...[
                          // Discount Label
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "20% OFF",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Price (Crossed out)
                          Text(
                            formatCurrency(originalPrice),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        // Discounted Price (or Normal Price)
                        Text(
                          formatCurrency(item.product.sellPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Quantity
                    Text(
                      "x${item.quantity}",
                      style: const TextStyle(fontSize: 14),
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
