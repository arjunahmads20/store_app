import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/product/domain/product.dart';

class MembershipProductCard extends StatelessWidget {
  final Product product;

  const MembershipProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${product.parentProductId}', extra: product);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.pictureUrl != null
                    ? Image.network(
                        product.pictureUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          size: 10,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${product.pointEarned} Pts",
                        style: TextStyle(
                          color: Colors.amber.shade200,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
