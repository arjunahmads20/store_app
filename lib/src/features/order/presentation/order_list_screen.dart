import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store_app/src/features/order/domain/order.dart';
import 'package:store_app/src/features/order/presentation/order_controller.dart';
import 'package:store_app/src/features/order/presentation/widgets/order_card.dart';
import 'package:store_app/src/features/order/presentation/widgets/order_filter_sheet.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  final String? initialStatusFilter;

  const OrderListScreen({super.key, this.initialStatusFilter});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Apply initial filter if present
    if (widget.initialStatusFilter != null) {
      // Use Future.microtask to avoid build phase errors
      Future.microtask(() {
        ref
            .read(orderControllerProvider.notifier)
            .setStatusFilter(widget.initialStatusFilter!);
      });
    }
  }

  @override
  void didUpdateWidget(OrderListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatusFilter != null &&
        widget.initialStatusFilter != oldWidget.initialStatusFilter) {
      Future.microtask(() {
        ref
            .read(orderControllerProvider.notifier)
            .setStatusFilter(widget.initialStatusFilter!);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(orderControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderControllerProvider);
    final orderState = orderAsync.value ?? OrderState(isLoading: true);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _StatusChip(
                          label: 'All',
                          isSelected: orderState.statusFilter == 'All',
                          onTap: () => ref
                              .read(orderControllerProvider.notifier)
                              .setStatusFilter('All'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Pending',
                          isSelected: orderState.statusFilter == 'Pending',
                          onTap: () => ref
                              .read(orderControllerProvider.notifier)
                              .setStatusFilter('Pending'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Processed',
                          isSelected: orderState.statusFilter == 'Processed',
                          onTap: () => ref
                              .read(orderControllerProvider.notifier)
                              .setStatusFilter('Processed'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Shipped',
                          isSelected: orderState.statusFilter == 'Shipped',
                          onTap: () => ref
                              .read(orderControllerProvider.notifier)
                              .setStatusFilter('Shipped'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Finished',
                          isSelected: orderState.statusFilter == 'Finished',
                          onTap: () => ref
                              .read(orderControllerProvider.notifier)
                              .setStatusFilter('Finished'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Cancelled',
                          isSelected: orderState.statusFilter == 'Cancelled',
                          onTap: () => ref
                              .read(orderControllerProvider.notifier)
                              .setStatusFilter('Cancelled'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) => const OrderFilterSheet(),
                          );
                        },
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text("Filter"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: Colors.grey.shade300),
                          backgroundColor:
                              (orderState.deliveryTypeFilter != null ||
                                  orderState.paymentMethodFilter != null)
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Order List
            Expanded(
              child: orderState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orderState.orders.isEmpty
                  ? const Center(child: Text("No orders found."))
                  : _buildGroupedList(
                      orderState.orders,
                      orderState.isLoadingMore,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(List<Order> orders, bool isLoadingMore) {
    // Flatten logic
    final flattened = <dynamic>[];
    String? lastMonthYear;

    for (var order in orders) {
      final date = order.datetimeCreated;
      final monthYear = DateFormat('MMMM yyyy').format(date);

      if (monthYear != lastMonthYear) {
        flattened.add(monthYear);
        lastMonthYear = monthYear;
      }
      flattened.add(order);
    }

    if (isLoadingMore) {
      flattened.add(const _LoadingIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final item = flattened[index];
        if (item is String) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              item,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        } else if (item is Order) {
          return OrderCard(order: item);
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // Marker class logic handled in builder
  }
}
