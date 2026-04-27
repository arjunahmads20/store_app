import 'package:flutter/material.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class DiscountBadge extends StatelessWidget {
  final int discountPercent;
  final bool isFlashSale;
  final double fontSize;
  final double? iconSize;

  const DiscountBadge({
    super.key,
    required this.discountPercent,
    this.isFlashSale = false,
    this.fontSize = 10,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFlashSale ? Colors.orange : AppColors.error,
        gradient: isFlashSale
            ? const LinearGradient(colors: [Colors.orange, Colors.redAccent])
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isFlashSale
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFlashSale)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                Icons.flash_on,
                size: iconSize ?? fontSize,
                color: Colors.white,
              ),
            ),
          Text(
            '$discountPercent% OFF',
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
}
