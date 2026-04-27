import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/order/presentation/order_controller.dart';

class OrderFilterSheet extends ConsumerStatefulWidget {
  const OrderFilterSheet({super.key});

  @override
  ConsumerState<OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends ConsumerState<OrderFilterSheet> {
  int? _selectedDeliveryType;
  int? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    final currentState =
        ref.read(orderControllerProvider).value ?? OrderState();
    _selectedDeliveryType = currentState.deliveryTypeFilter;
    _selectedPaymentMethod = currentState.paymentMethodFilter;
  }

  void _apply() {
    ref
        .read(orderControllerProvider.notifier)
        .setAdvancedFilters(
          deliveryTypeId: _selectedDeliveryType,
          paymentMethodId: _selectedPaymentMethod,
        );
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _selectedDeliveryType = null;
      _selectedPaymentMethod = null;
    });
    ref.read(orderControllerProvider.notifier).clearAdvancedFilters();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryTypesAsync = ref.watch(deliveryTypesProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter Orders",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Delivery Type Section
          Text(
            "Delivery Type",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          deliveryTypesAsync.when(
            data: (types) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: types.map((type) {
                final isSelected = _selectedDeliveryType == type.id;
                return ChoiceChip(
                  label: Text(type.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDeliveryType = selected ? type.id : null;
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? AppColors.primary : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Failed to load delivery types'),
          ),

          const SizedBox(height: 24),

          // Payment Method Section
          Text(
            "Payment Method",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          paymentMethodsAsync.when(
            data: (methods) => DropdownButtonFormField<int>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: methods
                  .map(
                    (method) => DropdownMenuItem(
                      value: method.id,
                      child: Text(method.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              hint: const Text('Select Payment Method'),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Failed to load payment methods'),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
