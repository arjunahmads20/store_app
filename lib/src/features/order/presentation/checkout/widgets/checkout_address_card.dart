import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class CheckoutAddressCard extends ConsumerWidget {
  final UserAddress? selectedAddress;
  final VoidCallback onTap;

  const CheckoutAddressCard({
    super.key,
    required this.selectedAddress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Address",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (selectedAddress != null) ...[
                      Text(
                        selectedAddress!.receiverName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        selectedAddress!.receiverPhoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedAddress!.fullAddress,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else
                      const Text(
                        "Select Address",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
