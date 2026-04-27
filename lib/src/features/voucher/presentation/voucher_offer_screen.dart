import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/voucher/data/voucher_repository.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

// --- Controller ---

class VoucherOfferState {
  final List<VoucherOrder> vouchers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  VoucherOfferState({
    this.vouchers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  VoucherOfferState copyWith({
    List<VoucherOrder>? vouchers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return VoucherOfferState(
      vouchers: vouchers ?? this.vouchers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

final voucherListControllerProvider =
    AsyncNotifierProvider.autoDispose<VoucherListController, VoucherOfferState>(
      VoucherListController.new,
    );

class VoucherListController extends AsyncNotifier<VoucherOfferState> {
  static const int _pageSize = 10;
  bool _mounted = true;

  @override
  FutureOr<VoucherOfferState> build() {
    ref.onDispose(() => _mounted = false);
    Future.microtask(() => _fetchVouchers(refresh: true));
    return VoucherOfferState(isLoading: true);
  }

  Future<void> _fetchVouchers({bool refresh = false}) async {
    if (!_mounted) return;
    final currentState = state.value ?? VoucherOfferState(isLoading: true);

    if (refresh) {
      if (!_mounted) return;
      state = AsyncData(
        currentState.copyWith(
          isLoading: true,
          error: null,
          vouchers: [],
          page: 1,
          hasMore: true,
        ),
      );
    } else {
      if (currentState.isLoading ||
          currentState.isLoadingMore ||
          !currentState.hasMore)
        return;
      if (!_mounted) return;
      state = AsyncData(
        currentState.copyWith(isLoadingMore: true, error: null),
      );
    }

    try {
      final pageToFetch = refresh ? 1 : (state.value?.page ?? 1) + 1;
      final newVouchers = await ref
          .read(voucherRepositoryProvider)
          .getVoucherOrders(
            sourceType: 'offer',
            page: pageToFetch,
            pageSize: _pageSize,
          );
      if (!_mounted) return;

      final hasMore = newVouchers.length >= _pageSize;
      final currentVouchers = refresh
          ? <VoucherOrder>[]
          : (state.value?.vouchers ?? []);

      state = AsyncData(
        currentState.copyWith(
          isLoading: false,
          isLoadingMore: false,
          vouchers: [...currentVouchers, ...newVouchers],
          page: pageToFetch,
          hasMore: hasMore,
        ),
      );
    } catch (e, st) {
      if (!_mounted) return;
      state = AsyncData(
        (state.value ?? VoucherOfferState()).copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: e.toString(),
        ),
      );
    }
  }

  void loadNextPage() => _fetchVouchers(refresh: false);
  void refresh() => _fetchVouchers(refresh: true);

  Future<bool> claimVoucherOrder(int voucherOrderId) async {
    try {
      await ref
          .read(voucherRepositoryProvider)
          .claimVoucherOrder(voucherOrderId: voucherOrderId);

      if (!_mounted) return false;
      final current = state.value;
      if (current != null) {
        final updatedList = current.vouchers
            .where((v) => v.id != voucherOrderId)
            .toList();
        state = AsyncData(current.copyWith(vouchers: updatedList));
      }
      return true;
    } catch (e, st) {
      return false;
    }
  }
}

// --- Screen ---

class VoucherOfferScreen extends ConsumerWidget {
  const VoucherOfferScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(voucherListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voucher Offers"),
        leading: const BackButton(),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (state) {
            if (state.isLoading && state.vouchers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.vouchers.isEmpty && !state.isLoading) {
              return const Center(
                child: Text("No vouchers available at the moment."),
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent * 0.9 &&
                    !state.isLoadingMore &&
                    state.hasMore) {
                  ref
                      .read(voucherListControllerProvider.notifier)
                      .loadNextPage();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.read(voucherListControllerProvider.notifier).refresh();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      state.vouchers.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == state.vouchers.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final voucher = state.vouchers[index];
                    return _VoucherBanner(voucher: voucher);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VoucherBanner extends ConsumerStatefulWidget {
  final VoucherOrder voucher;
  const _VoucherBanner({required this.voucher});

  @override
  ConsumerState<_VoucherBanner> createState() => _VoucherBannerState();
}

class _VoucherBannerState extends ConsumerState<_VoucherBanner> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160, // Fixed height for banner look
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Graphic (Placeholder circles)
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.voucher.discountPercentage.toStringAsFixed(0)}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.voucher.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.voucher.description != null)
                        Text(
                          widget.voucher.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          Text(
                            "Min: ${formatCurrency(widget.voucher.minItemCost)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                          if (widget.voucher.maxNominalDiscount != null)
                            Text(
                              "Max Disc: ${formatCurrency(widget.voucher.maxNominalDiscount!)}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Claim Button
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isClaiming
                        ? null
                        : () async {
                            setState(() => _isClaiming = true);
                            final success = await ref
                                .read(voucherListControllerProvider.notifier)
                                .claimVoucherOrder(widget.voucher.id);
                            if (mounted) {
                              setState(() => _isClaiming = false);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Voucher Claimed Successfully!",
                                    ),
                                  ),
                                );
                              } else {
                                final error = ref
                                    .read(voucherListControllerProvider)
                                    .error;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed: $error")),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: _isClaiming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Claim",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
