import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';

class AddressCard extends StatelessWidget {
  final UserAddress address;
  final VoidCallback? onSetMain;
  final VoidCallback? onEdit; // Added
  final bool isSelected;

  const AddressCard({
    super.key,
    required this.address,
    this.onSetMain,
    this.onEdit, // Added
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Extract details
    // Extract details directly from new flattened fields
    final villageName = address.villageDetail?['name'] ?? '';
    final districtName = address.districtDetail?['name'] ?? '';
    final regencyName = address.regencyDetail?['name'] ?? '';
    final streetName =
        address.streetDetail?['name'] ?? 'Street ID: ${address.streetId}';

    // Construct hierarchy string
    final List<String> locationParts = [];
    if (villageName.isNotEmpty) locationParts.add('Village: $villageName');
    if (districtName.isNotEmpty) locationParts.add('District: $districtName');
    if (regencyName.isNotEmpty) locationParts.add('$regencyName');
    final locationString = locationParts.join(', ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isMainAddress
              ? AppColors.primary
              : Colors.grey.shade200,
          width: address.isMainAddress ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Type + Main Label + Set Main Button (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    address.isOffice ? Icons.business : Icons.home,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.isOffice ? 'Office' : 'Home',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (address.isMainAddress) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Main',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  if (!address.isMainAddress && onSetMain != null) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onSetMain,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Set as main',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Receiver Info
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                address.receiverName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                address.receiverPhoneNumber,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streetName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (locationString.isNotEmpty)
                      Text(
                        locationString,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
