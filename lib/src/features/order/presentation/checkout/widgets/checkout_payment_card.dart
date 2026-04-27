import 'package:flutter/material.dart';
import 'package:store_app/src/features/payment/domain/payment_method.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

class CheckoutPaymentCard extends StatelessWidget {
  final PaymentMethod? selectedPaymentMethod;
  final VoidCallback onTap;

  const CheckoutPaymentCard({
    super.key,
    required this.selectedPaymentMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Payment Method",
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.payment_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedPaymentMethod != null) ...[
                          Text(
                            selectedPaymentMethod!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Checking if there is a fee
                          if (selectedPaymentMethod!.fee > 0)
                            Text(
                              "Fee: ${formatCurrency(selectedPaymentMethod!.fee)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ] else
                          const Text("Select Payment Method"),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
