import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/cart/presentation/widgets/cart_badge.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () =>
              context.push('/discover'), // Link to Search/Discover page
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search products...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const CartBadge(color: Colors.black),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 0. Categories Grid (Enhanced)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    categoriesValue.when(
                      data: (categories) => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: categories.length, // Show ALL categories
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to Discover with filter
                              context.push(
                                Uri(
                                  path: '/discover',
                                  queryParameters: {
                                    'category': category.id.toString(),
                                  },
                                ).toString(),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                  child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(
                                            category.iconUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.category_outlined, size: 24, color: AppColors.primary),
                                          ),
                                        )
                                      : Icon(
                                          Icons.category_outlined,
                                          size: 24,
                                          color: AppColors.primary,
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Center(
                        child: Text('Failed to load categories'),
                      ),
                    ),
                  ],
                ),
              ),

              // Hero Section (Banner)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
                    ), // Mock banner
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    'Browse Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Categories Sections
              categoriesValue.when(
                data: (categories) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategorySection(category: category);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                    const Center(child: Text('Failed to load categories')),
              ),
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final dynamic
  category; // Using dynamic or exact type to avoid import hell if needed, but better use exact

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine category ID and Name safely
    final String categoryId = category.id;
    final String categoryName = category.name;

    final productsValue = ref.watch(categoryProductsProvider(categoryId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to a dedicated list page for this category?
                  // For now just discover with filter
                  context.push(
                    Uri(
                      path: '/discover',
                      queryParameters: {'category': categoryId},
                    ).toString(),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280, // Taller for cards
          child: productsValue.when(
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text("No products in this category"),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 160,
                  child: ProductCard(product: products[index]),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}
