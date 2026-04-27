import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/core/utils/currency_formatter.dart';
import 'package:store_app/src/features/membership/data/membership_repository.dart';
import 'package:store_app/src/features/membership/domain/membership_reward.dart';
import 'package:store_app/src/features/voucher/data/voucher_repository.dart';

// --- Controller ---

class MembershipRewardListState {
  final List<MembershipReward> rewards;
  final bool isLoading;
  final String? error;

  MembershipRewardListState({
    this.rewards = const [],
    this.isLoading = false,
    this.error,
  });

  MembershipRewardListState copyWith({
    List<MembershipReward>? rewards,
    bool? isLoading,
    String? error,
  }) {
    return MembershipRewardListState(
      rewards: rewards ?? this.rewards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final membershipRewardListControllerProvider =
    AsyncNotifierProvider.autoDispose<
      MembershipRewardListController,
      MembershipRewardListState
    >(MembershipRewardListController.new);

class MembershipRewardListController
    extends AsyncNotifier<MembershipRewardListState> {
  @override
  FutureOr<MembershipRewardListState> build() async {
    return _fetchRewards();
  }

  Future<MembershipRewardListState> _fetchRewards() async {
    state = AsyncValue.data(MembershipRewardListState(isLoading: true));
    try {
      final rewards = await ref
          .read(membershipRepositoryProvider)
          .getMembershipRewards();
      return MembershipRewardListState(rewards: rewards, isLoading: false);
    } catch (e, st) {
      return MembershipRewardListState(isLoading: false, error: e.toString());
    }
  }

  Future<void> claimReward(MembershipReward reward) async {
    try {
      if (reward is PointMembershipReward) {
        await ref
            .read(membershipRepositoryProvider)
            .claimPointMembershipReward(pointMembershipRewardId: reward.id);
      } else if (reward is VoucherOrderMembershipReward) {
        // We use voucherOrderId because the reward is a wrapping around VoucherOrder
        // But the reward itself has an ID.
        // Wait, claimVoucherOrder takes voucherOrderId?
        // Let's check repository: claimVoucherOrder({int? voucherOrderId, String? code})
        // The API likely expects the VoucherOrder ID, not the Reward ID for vouchers?
        // Or maybe Membership Reward claiming is DIFFERENT from general voucher claiming?
        // User request said: "voucher can be claimed by using claimVoucherOrder".
        // claimVoucherOrder claims a SPECIFIC voucher order (template).
        // The Reward object contains the VoucherOrder.
        // So we should pass `reward.voucherOrderId` (or `reward.voucherOrder.id`).

        await ref
            .read(voucherRepositoryProvider)
            .claimVoucherOrder(voucherOrderId: reward.voucherOrderId);
      }

      // Refresh list to show updated status? Or just show success.
      // Usually rewards might be one-time or multi-time.
      // If one time, it might disappear or show as claimed.
      // For now, just refresh implementation.
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

// --- Screen ---

class MembershipRewardListScreen extends ConsumerWidget {
  const MembershipRewardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(membershipRewardListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Rewards"),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Navigate to history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Navigate to Reward History")),
              );
            },
            child: const Text("History"),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (state) {
            if (state.isLoading)
              return const Center(child: CircularProgressIndicator());
            if (state.error != null)
              return Center(child: Text('Error: ${state.error}'));
            if (state.rewards.isEmpty)
              return const Center(
                child: Text("No rewards available at the moment."),
              );

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.rewards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final reward = state.rewards[index];
                return _RewardCard(reward: reward);
              },
            );
          },
        ),
      ),
    );
  }
}

class _RewardCard extends ConsumerStatefulWidget {
  final MembershipReward reward;

  const _RewardCard({required this.reward});

  @override
  ConsumerState<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends ConsumerState<_RewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  bool _isClaiming = false;
  bool _isClaimed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    setState(() => _isClaiming = true);
    try {
      await ref
          .read(membershipRewardListControllerProvider.notifier)
          .claimReward(widget.reward);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reward claimed successfully!")),
        );
        setState(() => _isClaimed = true);
        await _controller.reverse();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPoint = widget.reward is PointMembershipReward;
    final gradientColors = isPoint
        ? [Colors.amber.shade700, Colors.amber.shade400]
        : [Colors.blue.shade800, Colors.blue.shade400];

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPoint
                          ? Icons.monetization_on
                          : Icons.confirmation_number,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPoint) ...[
                          Text(
                            "${(widget.reward as PointMembershipReward).pointEarned}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Points",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ] else if (widget.reward
                            is VoucherOrderMembershipReward) ...[
                          Text(
                            "${(widget.reward as VoucherOrderMembershipReward).voucherOrder?.discountPercentage.toStringAsFixed(0) ?? 0}% OFF",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            (widget.reward as VoucherOrderMembershipReward)
                                    .voucherOrder
                                    ?.name ??
                                "Voucher",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isClaiming || _isClaimed ? null : _handleClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradientColors.first,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    child: _isClaiming
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: gradientColors.first,
                            ),
                          )
                        : const Text(
                            "Claim",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
