import 'package:flutter/material.dart';

class PointsBadge extends StatelessWidget {
  final int points;
  final double fontSize;
  final double iconSize;
  final bool
  isInverted; // For use on dark backgrounds (like Flash Sale gradient)

  const PointsBadge({
    super.key,
    required this.points,
    this.fontSize = 9,
    this.iconSize = 10,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isInverted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on, size: iconSize, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              "+$points Points",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on, size: iconSize, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '+$points Pts',
            style: TextStyle(
              color: Colors.amber.shade900,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
