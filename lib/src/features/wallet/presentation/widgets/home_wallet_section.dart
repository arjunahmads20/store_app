import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/wallet/data/wallet_repository.dart';

import 'package:store_app/src/features/auth/presentation/auth_controller.dart';

class HomeWalletSection extends ConsumerWidget {
  const HomeWalletSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletValue = ref.watch(userWalletProvider);

    void onAuthRequired(VoidCallback action) {
      final user = ref.read(authControllerProvider).value;
      if (user == null) {
        context.go('/login');
      } else {
        action();
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onAuthRequired(() => context.push('/wallet')),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Balance',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      walletValue.when(
                        data: (wallet) {
                          if (wallet == null) {
                            return Text(
                              'Rp -',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            );
                          }
                          return Text(
                            wallet.formattedBalance,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          );
                        },
                        loading: () => const SizedBox(
                          height: 20,
                          width: 80,
                          child: LinearProgressIndicator(),
                        ),
                        error: (_, __) => const Text(
                          'Error',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                _ActionButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.plus,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  label: 'Topup',
                  onTap: () =>
                      onAuthRequired(() => context.push('/wallet/topup')),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.paperPlane,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  label: 'Transfer',
                  onTap: () =>
                      onAuthRequired(() => context.push('/wallet/transfer')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
