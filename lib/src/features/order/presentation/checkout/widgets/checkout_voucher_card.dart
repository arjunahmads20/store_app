import 'package:flutter/material.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class CheckoutVoucherCard extends StatelessWidget {
  final UserVoucherOrder? selectedVoucher;
  final VoidCallback onTap;

  const CheckoutVoucherCard({
    super.key,
    required this.selectedVoucher,
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
          child: Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    selectedVoucher != null &&
                        selectedVoucher!.voucherOrder != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedVoucher!.voucherOrder!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${selectedVoucher!.voucherOrder!.discountPercentage}% Off",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text("Use Voucher or Promo Code"),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
