import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/order/data/order_repository.dart';
import 'package:store_app/src/features/order/domain/delivery_type.dart';
import 'package:store_app/src/features/order/domain/order.dart';
import 'package:store_app/src/features/payment/data/payment_repository.dart';
import 'package:store_app/src/features/payment/domain/payment_method.dart';

// State Definition
class OrderState {
  final List<Order> orders;
  final bool isLoading; // Initial load
  final bool isLoadingMore; // Pagination load
  final String statusFilter;
  final int? deliveryTypeFilter;
  final int? paymentMethodFilter;
  final int page;
  final bool hasMore;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.statusFilter = 'All',
    this.deliveryTypeFilter,
    this.paymentMethodFilter,
    this.page = 1,
    this.hasMore = true,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    String? statusFilter,
    int? deliveryTypeFilter,
    int? paymentMethodFilter,
    int? page,
    bool? hasMore,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter: statusFilter ?? this.statusFilter,
      deliveryTypeFilter: deliveryTypeFilter ?? this.deliveryTypeFilter,
      paymentMethodFilter: paymentMethodFilter ?? this.paymentMethodFilter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Controller
class OrderController extends AsyncNotifier<OrderState> {
  static const int _pageSize = 10;

  @override
  FutureOr<OrderState> build() async {
    // Initial fetch handled by future microtask to avoid build delay or just init state and fetch
    // Better to return initial state and start fetch.
    // However, AsyncNotifier expects FutureOr data.
    // Let's return initial state with isLoading=true and fetch immediately.

    // We can't fire-and-forget strictly inside build easily without side effects,
    // but we can return the result of the first fetch.
    state = AsyncData(OrderState(isLoading: true));
    await _fetchOrders(refresh: true);
    return state.value!;
  }

  Future<void> _fetchOrders({bool refresh = false}) async {
    final currentState = state.value ?? OrderState();
    if (!refresh && (!currentState.hasMore || currentState.isLoadingMore))
      return;

    final page = refresh ? 1 : currentState.page + 1;

    if (refresh) {
      state = AsyncData(
        currentState.copyWith(isLoading: true, page: 1, orders: []),
      );
    } else {
      state = AsyncData(currentState.copyWith(isLoadingMore: true));
    }

    try {
      // Capture filters used for this request
      final requestStatusFilter = currentState.statusFilter;
      final requestDeliveryFilter = currentState.deliveryTypeFilter;
      final requestPaymentFilter = currentState.paymentMethodFilter;

      final repository = ref.read(orderRepositoryProvider);
      final newOrders = await repository.getOrders(
        page: page,
        pageSize: _pageSize,
        status: requestStatusFilter,
        deliveryTypeId: requestDeliveryFilter,
        paymentMethodId: requestPaymentFilter,
      );

      // Thread Safety Check:
      // If the filters in the current state have changed since we started this request,
      // it means a newer request (e.g., from setStatusFilter) has started.
      // We should discard this stale result to prevent overwriting the new state.
      final latestState = state.value;
      if (latestState != null) {
        if (latestState.statusFilter != requestStatusFilter ||
            latestState.deliveryTypeFilter != requestDeliveryFilter ||
            latestState.paymentMethodFilter != requestPaymentFilter) {
          return;
        }
      }

      final hasMore = newOrders.length >= _pageSize;

      final updatedOrders = refresh
          ? newOrders
          : [...currentState.orders, ...newOrders];

      state = AsyncData(
        currentState.copyWith(
          orders: updatedOrders,
          isLoading: false,
          isLoadingMore: false,
          page: page,
          hasMore: hasMore,
        ),
      );
    } catch (e, st) {
      // Also check if relevant? Usually errors should be shown,
      // but if we switched filters, maybe we don't care about old error.
      // But simpler to just set error usually. Use same check if strictly needed.
      state = AsyncError(e, st);
    }
  }

  Future<void> setStatusFilter(String status) async {
    final currentState = state.value ?? OrderState();
    if (currentState.statusFilter == status) return;

    state = AsyncData(currentState.copyWith(statusFilter: status));
    await _fetchOrders(refresh: true);
  }

  Future<void> setAdvancedFilters({
    int? deliveryTypeId,
    int? paymentMethodId,
  }) async {
    final currentState = state.value ?? OrderState();
    state = AsyncData(
      currentState.copyWith(
        deliveryTypeFilter: deliveryTypeId,
        paymentMethodFilter: paymentMethodId,
      ),
    );
    await _fetchOrders(refresh: true);
  }

  Future<void> clearAdvancedFilters() async {
    final currentState = state.value ?? OrderState();
    state = AsyncData(
      currentState.copyWith(
        deliveryTypeFilter: null, // explicit null
        paymentMethodFilter: null, // explicit null
      ),
    );
    // Force nulls in copyWith by using a wrapper or just creating new state logically?
    // Dart copyWith optional parameters don't easily support setting to null.
    // I need to update copyWith logic or manually construct.
    // Let's fix copyWith above? Or manually construct here.

    // Actually standard copyWith ignores null inputs.
    // To support nulling, I should pass a specific object or handle logic differently.
    // For now, I'll just re-create state but keep orders? No, need refresh.

    // Re-implementation for clear:
    state = AsyncData(
      OrderState(
        orders: [], // will be refreshed
        isLoading: true,
        statusFilter: currentState.statusFilter,
        deliveryTypeFilter: null,
        paymentMethodFilter: null,
      ),
    );
    await _fetchOrders(refresh: true);
  }

  Future<void> loadNextPage() async {
    await _fetchOrders(refresh: false);
  }

  Future<void> refresh() async {
    await _fetchOrders(refresh: true);
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(orderId);
      // Refresh list to reflect status change
      await _fetchOrders(refresh: true);
    } catch (e) {
      rethrow;
    }
  }
}

final orderControllerProvider =
    AsyncNotifierProvider.autoDispose<OrderController, OrderState>(
      OrderController.new,
    );

// Providers for Filter Options
final deliveryTypesProvider = FutureProvider.autoDispose<List<DeliveryType>>((
  ref,
) async {
  return ref.watch(orderRepositoryProvider).getDeliveryTypes();
});

final paymentMethodsProvider = FutureProvider.autoDispose<List<PaymentMethod>>((
  ref,
) async {
  return ref.watch(paymentRepositoryProvider).getPaymentMethods();
});
