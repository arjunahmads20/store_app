import 'package:flutter/material.dart';
import 'package:store_app/src/features/order/presentation/checkout/checkout_controller.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

class CheckoutSummary extends StatelessWidget {
  final CheckoutState state;

  const CheckoutSummary({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow("Subtotal for products", state.subtotal),
        _buildRow("Delivery Cost", state.deliveryCost),
        _buildRow("Admin Fee", state.adminFee),
        if (state.discountAmount > 0)
          _buildRow(
            "Voucher Discount",
            -state.discountAmount,
            isDiscount: true,
          ),
        // Add payment fees if logic exists in state
        const Divider(height: 24),
        _buildRow("Total Payment", state.total, isBold: true, fontSize: 16),
      ],
    );
  }

  Widget _buildRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
