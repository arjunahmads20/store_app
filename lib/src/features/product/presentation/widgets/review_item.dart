import 'package:flutter/material.dart';
import 'package:store_app/src/features/product/domain/review.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // Placeholder name
                  // Ideally display date here if available
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    "${review.rate}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (review.comment.isNotEmpty)
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, height: 1.5),
          )
        else
          const Text(
            "No comment.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
