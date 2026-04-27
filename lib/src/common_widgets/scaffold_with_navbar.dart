import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: NavigationBar(
          height: 60,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (int index) => _onTap(context, index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view), // Category
              selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: 'Category',
            ),
             NavigationDestination(
              icon: Icon(Icons.local_offer_outlined), // Promo
              selectedIcon: Icon(Icons.local_offer, color: AppColors.primary),
              label: 'Promo',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), // Orders
              selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
