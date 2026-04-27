import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/voucher/data/voucher_repository.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';

class UserVoucherListState {
  final List<UserVoucherOrder> vouchers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  UserVoucherListState({
    this.vouchers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  UserVoucherListState copyWith({
    List<UserVoucherOrder>? vouchers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return UserVoucherListState(
      vouchers: vouchers ?? this.vouchers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

final userVoucherListControllerProvider =
    AsyncNotifierProvider.autoDispose<
      UserVoucherListController,
      UserVoucherListState
    >(UserVoucherListController.new);

class UserVoucherListController extends AsyncNotifier<UserVoucherListState> {
  static const int _pageSize = 10;
  bool _mounted = true;

  @override
  FutureOr<UserVoucherListState> build() {
    ref.onDispose(() => _mounted = false);
    Future.microtask(() => _fetchVouchers(refresh: true));
    return UserVoucherListState(isLoading: true);
  }

  Future<void> _fetchVouchers({bool refresh = false}) async {
    if (!_mounted) return;
    final currentState = state.value ?? UserVoucherListState(isLoading: true);

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
          .getUserVouchers(page: pageToFetch, pageSize: _pageSize);
      if (!_mounted) return;

      final hasMore = newVouchers.length >= _pageSize;
      final currentVouchers = refresh
          ? <UserVoucherOrder>[]
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
        (state.value ?? UserVoucherListState()).copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: e.toString(),
        ),
      );
    }
  }

  void loadNextPage() => _fetchVouchers(refresh: false);
  void refresh() => _fetchVouchers(refresh: true);

  Future<void> claimByCode(String code) async {
    await ref.read(voucherRepositoryProvider).claimVoucherOrder(code: code);
    refresh();
  }
}

class UserVoucherListScreen extends ConsumerStatefulWidget {
  const UserVoucherListScreen({super.key});

  @override
  ConsumerState<UserVoucherListScreen> createState() =>
      _UserVoucherListScreenState();
}

class _UserVoucherListScreenState extends ConsumerState<UserVoucherListScreen> {
  bool _isExpanded = false;
  final TextEditingController _codeController = TextEditingController();
  bool _isClaiming = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _claimVoucherCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isClaiming = true);
    try {
      await ref
          .read(userVoucherListControllerProvider.notifier)
          .claimByCode(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Voucher claimed successfully!")),
        );
        _codeController.clear();
        setState(() => _isExpanded = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(userVoucherListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Vouchers")),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: [
            // Code Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!_isExpanded)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _isExpanded = true),
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: const Text("Enter voucher code"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              hintText: "Enter voucher code",
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isClaiming ? null : _claimVoucherCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isClaiming
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Apply"),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Voucher List
            Expanded(
              child: stateAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (state) {
                  if (state.isLoading && state.vouchers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.vouchers.isEmpty && !state.isLoading) {
                    return const Center(
                      child: Text("You haven't claimed any vouchers yet."),
                    );
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
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref
                            .read(userVoucherListControllerProvider.notifier)
                            .refresh();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            state.vouchers.length +
                            (state.isLoadingMore ? 1 : 0),
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
                          return _UserVoucherCard(
                            voucher: state.vouchers[index],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserVoucherCard extends StatelessWidget {
  final UserVoucherOrder voucher;

  const _UserVoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final voucherOrder = voucher.voucherOrder;
    if (voucherOrder == null) return const SizedBox.shrink();

    final isExpired =
        voucherOrder.datetimeExpiry != null &&
        voucherOrder.datetimeExpiry!.isBefore(DateTime.now());
    final isUsed = voucher.isUsed;
    final isAvailable = !isExpired && !isUsed;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isAvailable
              ? [Colors.blue.shade800, Colors.blue.shade400]
              : [Colors.grey.shade700, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAvailable ? Colors.blue : Colors.grey).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
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
                        "${voucherOrder.discountPercentage.toStringAsFixed(0)}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        voucherOrder.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (voucherOrder.description != null)
                        Text(
                          voucherOrder.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          Text(
                            "Min: ${formatCurrency(voucherOrder.minItemCost)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                          if (isExpired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Expired",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (isUsed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Used",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isAvailable
                        ? () => context.go('/category')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isAvailable
                          ? Colors.blue.shade800
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isUsed ? "USED" : (isExpired ? "EXPIRED" : "USE"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
