import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/order/presentation/checkout/checkout_controller.dart';
import 'package:store_app/src/features/order/presentation/checkout/widgets/checkout_address_card.dart';
import 'package:store_app/src/features/order/presentation/checkout/widgets/checkout_delivery_card.dart';
import 'package:store_app/src/features/order/presentation/checkout/widgets/checkout_payment_card.dart';
import 'package:store_app/src/features/order/presentation/checkout/widgets/checkout_product_card.dart';
import 'package:store_app/src/features/order/presentation/checkout/widgets/checkout_summary.dart';
import 'package:store_app/src/features/order/presentation/checkout/widgets/checkout_voucher_card.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';
import 'package:store_app/src/features/voucher/presentation/user_voucher_list_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required Function(T) onSelected,
    Future<void> Function()? onManage,
    String manageLabel = "Manage",
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                      child: itemBuilder(item),
                    );
                  },
                ),
              ),
              if (onManage != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await onManage();
                    },
                    icon: const Icon(Icons.add_location_alt),
                    label: Text(manageLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(checkoutControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
        data: (state) {
          if (state.cart == null || state.cart!.items.isEmpty) {
            return const Center(child: Text("Cart is empty"));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Address
                      CheckoutAddressCard(
                        selectedAddress: state.selectedAddress,
                        onTap: () => _showSelectionSheet(
                          title: "Select Address",
                          items: state.addresses,
                          itemBuilder: (addr) => ListTile(
                            title: Text(addr.receiverName),
                            subtitle: Text(
                              "${addr.receiverPhoneNumber}\n${addr.fullAddress}",
                            ),
                            isThreeLine: true,
                            trailing: addr.id == state.selectedAddress?.id
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          onSelected: (addr) => ref
                              .read(checkoutControllerProvider.notifier)
                              .selectAddress(addr),
                          onManage: () async {
                            await context.push('/profile/addresses');
                            ref
                                .read(checkoutControllerProvider.notifier)
                                .refresh();
                          },
                          manageLabel: "Add / Edit Address",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Delivery Type
                      CheckoutDeliveryCard(
                        selectedDeliveryType: state.selectedDeliveryType,
                        onTap: () => _showSelectionSheet(
                          title: "Select Delivery",
                          items: state.deliveryTypes,
                          itemBuilder: (type) => ListTile(
                            title: Text(type.name),
                            trailing: Text(formatCurrency(type.cost)),
                          ),
                          onSelected: (type) => ref
                              .read(checkoutControllerProvider.notifier)
                              .selectDeliveryType(type),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Products
                      Text(
                        "Order Items",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.cart!.items.length,
                        itemBuilder: (context, index) =>
                            CheckoutProductCard(item: state.cart!.items[index]),
                      ),
                      const SizedBox(height: 24),

                      // 4. Voucher
                      CheckoutVoucherCard(
                        selectedVoucher: state.selectedVoucher,
                        onTap: () => _showSelectionSheet(
                          title: "Select Voucher",
                          items: state.vouchers,
                          itemBuilder: (v) {
                            final isValid = state.isVoucherValid(v);
                            final order = v.voucherOrder;
                            if (order == null) return const SizedBox();
                            final isExpired =
                                order.datetimeExpiry != null &&
                                order.datetimeExpiry!.isBefore(DateTime.now());
                            if (isExpired) return const SizedBox();

                            final isSelected =
                                v.id == state.selectedVoucher?.id;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              height: 120, // Slightly smaller than full list
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: isValid
                                      ? [
                                          Colors.blue.shade800,
                                          Colors.blue.shade400,
                                        ]
                                      : [
                                          Colors.grey.shade700,
                                          Colors.grey.shade400,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isValid ? Colors.blue : Colors.grey)
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  // Decorative Circle
                                  Positioned(
                                    right: -15,
                                    top: -15,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${order.discountPercentage.toStringAsFixed(0)}% OFF",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                order.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              if (!isValid)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "Min: ${formatCurrency(order.minItemCost)}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Text(
                                                  "Min spend: ${formatCurrency(order.minItemCost)}",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 14,
                                            child: Icon(
                                              Icons.check,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onSelected: (v) {
                            // Allow selection but it won't apply if invalid (state.discountAmount handles it)
                            ref
                                .read(checkoutControllerProvider.notifier)
                                .selectVoucher(v);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Payment Method
                      CheckoutPaymentCard(
                        selectedPaymentMethod: state.selectedPaymentMethod,
                        onTap: () => _showSelectionSheet(
                          title: "Select Payment",
                          items: state.paymentMethods,
                          itemBuilder: (pm) => ListTile(
                            title: Text(pm.name),
                            subtitle: Text("Fee: ${formatCurrency(pm.fee)}"),
                            trailing: pm.id == state.selectedPaymentMethod?.id
                                ? const Icon(Icons.check)
                                : null,
                          ),
                          onSelected: (pm) => ref
                              .read(checkoutControllerProvider.notifier)
                              .selectPaymentMethod(pm),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Message for Driver
                      TextField(
                        controller: _messageController,
                        onChanged: (val) => ref
                            .read(checkoutControllerProvider.notifier)
                            .updateMessage(val),
                        decoration: InputDecoration(
                          labelText: "Message for Driver",
                          hintText: "E.g. Call upon arrival",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // 7. Summary
                      CheckoutSummary(state: state),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total Payment",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              formatCurrency(state.total),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              state.canPlaceOrder && !state.isPlacingOrder
                              ? () async {
                                  await ref
                                      .read(checkoutControllerProvider.notifier)
                                      .placeOrder();

                                  if (context.mounted) {
                                    // Check for error by looking at the *new* state
                                    final newState = ref.read(
                                      checkoutControllerProvider,
                                    );
                                    if (!newState.hasError) {
                                      final order = newState.value?.order;
                                      if (order != null &&
                                          order.transactionRedirectUrl !=
                                              null &&
                                          order
                                              .transactionRedirectUrl!
                                              .isNotEmpty) {
                                        // Navigate to Order List first so back button behavior is correct
                                        context.go('/orders?status=Pending');
                                        // Then push WebView
                                        Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                            if (context.mounted) {
                                              context.push(
                                                '/webview',
                                                extra: {
                                                  'url': order
                                                      .transactionRedirectUrl!,
                                                  'title': 'Payment',
                                                },
                                              );
                                            }
                                          },
                                        );
                                      } else {
                                        context.go('/orders?status=Pending');
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to place order: ${newState.error}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: state.isPlacingOrder
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Create Order"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VoucherSelectionSheet extends ConsumerStatefulWidget {
  const _VoucherSelectionSheet();

  @override
  ConsumerState<_VoucherSelectionSheet> createState() =>
      _VoucherSelectionSheetState();
}

class _VoucherSelectionSheetState
    extends ConsumerState<_VoucherSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(userVoucherListControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider).value;

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Voucher",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: voucherState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (state) {
                if (state.isLoading && state.vouchers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.vouchers.isEmpty && !state.isLoading) {
                  return const Center(child: Text("No vouchers available."));
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent * 0.9 &&
                        !state.isLoadingMore &&
                        state.hasMore) {
                      ref
                          .read(userVoucherListControllerProvider.notifier)
                          .loadNextPage();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount:
                        state.vouchers.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.vouchers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final v = state.vouchers[index];

                      final isValid = checkoutState?.isVoucherValid(v) ?? false;
                      final order = v.voucherOrder;
                      if (order == null) return const SizedBox();

                      final isSelected =
                          v.id == checkoutState?.selectedVoucher?.id;

                      return InkWell(
                        onTap: () {
                          ref
                              .read(checkoutControllerProvider.notifier)
                              .selectVoucher(v);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: isValid
                                  ? [Colors.blue.shade800, Colors.blue.shade400]
                                  : [
                                      Colors.grey.shade700,
                                      Colors.grey.shade400,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isValid ? Colors.blue : Colors.grey)
                                    .withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -15,
                                top: -15,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${order.discountPercentage.toStringAsFixed(0)}% OFF",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            order.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          if (!isValid)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                "Min: ${formatCurrency(order.minItemCost)}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          else
                                            Text(
                                              "Min spend: ${formatCurrency(order.minItemCost)}",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 14,
                                        child: Icon(
                                          Icons.check,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
