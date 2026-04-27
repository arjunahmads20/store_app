import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/product/data/flashsale_repository.dart';
import 'package:store_app/src/features/store/data/store_repository.dart';
import 'package:store_app/src/features/product/domain/flashsale.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:store_app/src/features/product/presentation/widgets/flashsale_countdown.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class FlashsaleScreen extends ConsumerStatefulWidget {
  const FlashsaleScreen({super.key});

  @override
  ConsumerState<FlashsaleScreen> createState() => _FlashsaleScreenState();
}

class _FlashsaleScreenState extends ConsumerState<FlashsaleScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final flashsalesValue = ref.watch(activeFlashsalesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: true,
        top: false,
        child: flashsalesValue.when(
          data: (flashsales) {
            if (flashsales.isEmpty) {
              return const Center(
                child: Text('No active flash sales right now.'),
              );
            }

            if (_tabController == null ||
                _tabController!.length != flashsales.length) {
              _tabController = TabController(
                length: flashsales.length,
                vsync: this,
              );
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    floating: false,
                    backgroundColor: AppColors.primary,
                    actions: [
                      IconButton(
                        onPressed: () => context.push('/voucher-offers'),
                        icon: const Icon(
                          Icons.confirmation_number_outlined,
                          color: Colors.white,
                        ),
                        tooltip: "Voucher Offers",
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        "Flash Sale",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 2),
                          ],
                        ),
                      ),
                      centerTitle: true,
                      background: AnimatedBuilder(
                        animation: _tabController!,
                        builder: (context, child) {
                          final index = _tabController!.index;
                          final fs = flashsales[index];
                          if (fs.bannerUrl != null) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(fs.bannerUrl!, fit: BoxFit.cover),
                                Container(color: Colors.black26),
                              ],
                            );
                          }
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -30,
                                  top: -30,
                                  child: Icon(
                                    Icons.flash_on,
                                    size: 200,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                Positioned(
                                  left: -20,
                                  bottom: -20,
                                  child: Icon(
                                    Icons.flash_on,
                                    size: 150,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.primary,
                        tabs: flashsales
                            .map((fs) => Tab(text: fs.name))
                            .toList(),
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: flashsales
                    .map((fs) => _FlashsaleProductList(flashsale: fs))
                    .toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class _FlashsaleProductList extends ConsumerWidget {
  final Flashsale flashsale;
  const _FlashsaleProductList({required this.flashsale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsValue = ref.watch(flashsaleProductsProvider(flashsale.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FlashsaleCountdown(endTime: flashsale.endDateTime),
        ),
        Expanded(
          child: productsValue.when(
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text('No items in this flash sale.'),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading products: $e')),
          ),
        ),
      ],
    );
  }
}

final flashsaleProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  id,
) async {
  final products = await ref
      .watch(flashsaleRepositoryProvider)
      .getFlashsaleProducts(id);
  final store = await ref.watch(nearestStoreProvider.future);

  if (store != null) {
    return products.where((p) => p.storeId == store.id).toList();
  }
  return products;
});
