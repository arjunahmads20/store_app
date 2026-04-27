import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/membership/domain/membership.dart';
import 'package:store_app/src/features/membership/domain/user_membership_model.dart';
import 'package:store_app/src/features/membership/presentation/membership_controller.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/membership/presentation/widgets/membership_product_card.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membershipControllerProvider);
    final userMembership = state.userMembership;
    final currentTier = state.currentMembershipDetail;

    if (state.isLoading) {
      return const Scaffold(
        body: SafeArea(
          bottom: true,
          top: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Membership'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debug
                if (userMembership == null)
                  const Center(
                    child: Text(
                      "Error: No userMembership Data",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (currentTier == null)
                  const Center(
                    child: Text(
                      "Error: No currentTier Data",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                // 1. Membership Card
                if (userMembership != null && currentTier != null)
                  _buildMembershipCard(context, userMembership, currentTier)
                else
                  const Center(
                    child: Text(
                      "No Membership Data",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                const SizedBox(height: 16),

                // 2. Membership Info (Dates)
                if (userMembership != null) _buildInfoSection(userMembership),

                const SizedBox(height: 24),

                // 3. Action Buttons
                _buildActionButtons(context),

                const SizedBox(height: 32),

                // 4. Products with Points
                if (state.productsWithPoints.isNotEmpty) ...[
                  Text(
                    "Get More Points",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProductList(context, state.productsWithPoints),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipCard(
    BuildContext context,
    UserMembership userMembership,
    Membership tier,
  ) {
    // Determine color based on tier? Defaulting to Gold/Orange theme
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Info Icon
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                context.push('/profile/membership/detail?id=${tier.id}');
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Level ${tier.level}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Badge Icon
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 32.0,
                    ), // Give space for info icon if needed, or just layout
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${userMembership.point}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      "Points",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: userMembership.levelUpPoint > 0
                          ? userMembership.point / userMembership.levelUpPoint
                          : 0.0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (tier.next_membership_name != null)
                    Text(
                      "${userMembership.levelUpPoint} points to ${tier.next_membership_name}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(UserMembership userMembership) {
    final start = userMembership.datetimeAttached != null
        ? DateFormat('d MMM yyyy').format(userMembership.datetimeAttached!)
        : '-';
    final end = userMembership.datetimeEnded != null
        ? DateFormat('d MMM yyyy').format(userMembership.datetimeEnded!)
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Membership Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, "Started", start),
          Divider(height: 24, color: Colors.white.withOpacity(0.2)),
          _buildInfoRow(Icons.event_busy, "Valid Until", end),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildActionButton(
          context,
          "Rewards",
          Icons.card_giftcard,
          Colors.pink,
          () {
            context.push('/profile/membership-rewards');
          },
        ),
        _buildActionButton(
          context,
          "Details",
          Icons.info_outline,
          Colors.blue,
          () {
            context.push('/profile/membership/detail');
          },
        ),
        _buildActionButton(
          context,
          "Redeem",
          Icons.shopping_bag_outlined,
          Colors.purple,
          () {
            // Navigate to Redeem List
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Redeem Points - Coming Soon")),
            );
          },
        ),
        _buildActionButton(
          context,
          "History",
          Icons.history,
          Colors.orange,
          () {
            // Navigate to Point History
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Point History - Coming Soon")),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<Product> products) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];

          return MembershipProductCard(product: product);
        },
      ),
    );
  }
}
