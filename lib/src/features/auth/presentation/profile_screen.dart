import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/features/membership/data/membership_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          bottom: true,
          top: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Profile Section ---
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.phoneNumber,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),

                        // Email Verification
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.email,
                                style: const TextStyle(color: Colors.blue),
                              ),
                              const SizedBox(width: 8),
                              // Placeholder for verification status
                              const Text(
                                "· Verified",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Membership Widget
                        Consumer(
                          builder: (context, ref, _) {
                            final membershipAsync = ref.watch(
                              userMembershipProvider,
                            );
                            return membershipAsync.when(
                              data: (membership) {
                                if (membership == null)
                                  return const SizedBox.shrink();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () =>
                                          context.push('/profile/membership'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.stars,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Membership",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "${membership.point} Points",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              loading: () =>
                                  const SizedBox.shrink(), // Or shimmer
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Invite Friends"),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          context.push('/profile/edit');
                        },
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- Menu Section ---
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.favorite_border,
                      title: "Product Favorite",
                      onTap: () {},
                    ),
                    _ProfileMenuTile(
                      icon: Icons.confirmation_number_outlined,
                      title: "My Vouchers",
                      onTap: () => context.push('/profile/vouchers'),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.mail_outline,
                      title: "Inbox List",
                      onTap: () {},
                    ),
                    _ProfileMenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Wallet",
                      onTap: () => context.push('/wallet'),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.card_membership,
                      title: "Membership",
                      onTap: () => context.push('/profile/membership'),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.location_on_outlined,
                      title: "Address",
                      onTap: () => context.push('/profile/addresses'),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.group_add_outlined,
                      title: "Invitation",
                      onTap: () {},
                    ),
                    _ProfileMenuTile(
                      icon: Icons.payment,
                      title: "Payment Method",
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () {},
                    ),
                    _ProfileMenuTile(
                      icon: Icons.help_outline,
                      title: "Help",
                      onTap: () {},
                    ),
                    _ProfileMenuTile(
                      icon: Icons.star_border,
                      title: "Rate Us",
                      onTap: () {},
                    ),
                    _ProfileMenuTile(
                      icon: Icons.logout,
                      title: "Logout",
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
