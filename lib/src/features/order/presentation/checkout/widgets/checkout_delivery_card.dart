import 'package:flutter/material.dart';
import 'package:store_app/src/features/order/domain/delivery_type.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

class CheckoutDeliveryCard extends StatelessWidget {
  final DeliveryType? selectedDeliveryType;
  final VoidCallback onTap;

  const CheckoutDeliveryCard({
    super.key,
    required this.selectedDeliveryType,
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
                "Delivery Option",
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedDeliveryType != null) ...[
                          Text(
                            selectedDeliveryType!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatCurrency(selectedDeliveryType!.cost),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            "Estimates: 1-2 Days",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ), // Static for now
                        ] else
                          const Text("Select Delivery Method"),
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
