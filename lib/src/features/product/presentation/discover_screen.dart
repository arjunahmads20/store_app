import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/presentation/discover_controller.dart';
import 'package:store_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:store_app/src/features/product/presentation/widgets/discover_filter_sheet.dart';
import 'package:store_app/src/features/cart/presentation/widgets/cart_badge.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      final categoryId = state.uri.queryParameters['category'];
      if (categoryId != null) {
        ref.read(discoverControllerProvider.notifier).setCategory(categoryId);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(discoverControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(discoverControllerProvider.notifier).setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesValue = ref.watch(categoriesProvider);
    final discoverAsync = ref.watch(discoverControllerProvider);
    final discoverState = discoverAsync.value ?? DiscoverState(isLoading: true);

    return WillPopScope(
      onWillPop: () async {
        context.go('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus:
                false, // Don't auto focus to avoid keyboard popping immediately
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            const CartBadge(color: Colors.black),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filters
                  categoriesValue.when(
                    data: (categories) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: discoverState.selectedCategory == 'All',
                            onTap: () => ref
                                .read(discoverControllerProvider.notifier)
                                .setCategory('All'),
                          ),
                          const SizedBox(width: 8),
                          ...categories.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _FilterChip(
                                label: category.name,
                                isSelected:
                                    discoverState.selectedCategory ==
                                    category.id,
                                onTap: () => ref
                                    .read(discoverControllerProvider.notifier)
                                    .setCategory(category.id),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 32,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, st) => const SizedBox(),
                  ),
                  const SizedBox(height: 12),
                  // Other Filters (Sort, etc.)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (context) => const DiscoverSortSheet(),
                            );
                          },
                          icon: const Icon(Icons.sort, size: 18),
                          label: const Text("Sort"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: (discoverState.sortBy != null)
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (context) => const DiscoverFilterSheet(),
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
                                (discoverState.minPrice != null ||
                                    discoverState.maxPrice != null ||
                                    discoverState.isSupportCod ||
                                    discoverState.isSupportInstantDelivery ||
                                    discoverState.isContainPoints)
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => ref
                              .read(discoverControllerProvider.notifier)
                              .toggleFilter(
                                instant:
                                    !discoverState.isSupportInstantDelivery,
                              ),
                          icon: Icon(
                            discoverState.isSupportInstantDelivery
                                ? Icons.check
                                : Icons.local_shipping_outlined,
                            size: 18,
                          ),
                          label: const Text("Instant"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            foregroundColor:
                                discoverState.isSupportInstantDelivery
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            backgroundColor:
                                discoverState.isSupportInstantDelivery
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.white,
                            side: BorderSide(
                              color: discoverState.isSupportInstantDelivery
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: discoverState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : discoverState.products.isEmpty && !discoverState.isLoading
                  ? const Center(child: Text("No products found."))
                  : CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.60,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return ProductCard(
                                product: discoverState.products[index],
                              );
                            }, childCount: discoverState.products.length),
                          ),
                        ),
                        if (discoverState.isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
          ),
        ),
      ),
    );
  }
}
