import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/store/data/store_repository.dart';
import 'package:store_app/src/features/product/domain/product.dart';

// State classes
class DiscoverState {
  // Filters
  final String searchQuery;
  final String selectedCategory; // 'All' or ID
  final double? minPrice;
  final double? maxPrice;
  final bool isSupportCod;
  final bool isSupportInstantDelivery;
  final bool isContainPoints;
  final String? sortBy; // 'name', 'sell_price', 'sold_count', 'category'
  final bool sortDescending;

  // Pagination & Data
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  DiscoverState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.minPrice,
    this.maxPrice,
    this.isSupportCod = false,
    this.isSupportInstantDelivery = false,
    this.isContainPoints = false,
    this.sortBy,
    this.sortDescending = false,
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  DiscoverState copyWith({
    String? searchQuery,
    String? selectedCategory,
    double? minPrice,
    double? maxPrice,
    bool? isSupportCod,
    bool? isSupportInstantDelivery,
    bool? isContainPoints,
    String? sortBy,
    bool? sortDescending,
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return DiscoverState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isSupportCod: isSupportCod ?? this.isSupportCod,
      isSupportInstantDelivery:
          isSupportInstantDelivery ?? this.isSupportInstantDelivery,
      isContainPoints: isContainPoints ?? this.isContainPoints,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

// Controller
class DiscoverController extends AsyncNotifier<DiscoverState> {
  static const int _pageSize = 10;
  bool _mounted = true;

  @override
  FutureOr<DiscoverState> build() {
    ref.onDispose(() => _mounted = false);
    // Initial fetch
    Future.microtask(() => _fetchProducts(refresh: true));
    return DiscoverState(isLoading: true);
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    if (!_mounted) return;
    final currentState = state.value ?? DiscoverState(isLoading: true);

    if (refresh) {
      if (!_mounted) return;
      state = AsyncData(
        currentState.copyWith(
          isLoading: true,
          error: null,
          products: [],
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
      final store = await ref.read(nearestStoreProvider.future);
      if (!_mounted) return;
      final storeId = store != null ? int.tryParse(store.id) : null;

      final loadingState = state.value ?? DiscoverState();
      final pageToFetch = refresh ? 1 : loadingState.page + 1;

      final newProducts = await ref
          .read(productRepositoryProvider)
          .getProducts(
            storeId: storeId,
            search: loadingState.searchQuery,
            categoryId: loadingState.selectedCategory,
            minPrice: loadingState.minPrice,
            maxPrice: loadingState.maxPrice,
            isSupportCod: loadingState.isSupportCod,
            isSupportInstantDelivery: loadingState.isSupportInstantDelivery,
            isContainPoints: loadingState.isContainPoints,
            sortBy: loadingState.sortBy,
            descending: loadingState.sortDescending,
            page: pageToFetch,
            pageSize: _pageSize,
          );
      if (!_mounted) return;

      final hasMore = newProducts.length >= _pageSize;
      final currentProducts = refresh ? <Product>[] : loadingState.products;

      if (refresh) {
        state = AsyncData(
          loadingState.copyWith(
            isLoading: false,
            products: newProducts,
            page: 1,
            hasMore: hasMore,
          ),
        );
      } else {
        state = AsyncData(
          loadingState.copyWith(
            isLoadingMore: false,
            products: [...currentProducts, ...newProducts],
            page: pageToFetch,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e, st) {
      if (!_mounted) return;
      // Ensure we have a valid state to copy from
      final errorState = state.value ?? DiscoverState();
      state = AsyncData(
        errorState.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: e.toString(),
        ),
      );
    }
  }

  // Public methods to trigger state changes

  void loadNextPage() {
    _fetchProducts(refresh: false);
  }

  void refresh() {
    _fetchProducts(refresh: true);
  }

  void setSearchQuery(String query) {
    final s = state.value ?? DiscoverState();
    if (s.searchQuery == query) return;
    state = AsyncData(s.copyWith(searchQuery: query));
    _fetchProducts(refresh: true);
  }

  void setCategory(String categoryId) {
    final s = state.value ?? DiscoverState();
    if (s.selectedCategory == categoryId) return;
    state = AsyncData(s.copyWith(selectedCategory: categoryId));
    _fetchProducts(refresh: true);
  }

  void setPriceRange(double? min, double? max) {
    final s = state.value ?? DiscoverState();
    state = AsyncData(s.copyWith(minPrice: min, maxPrice: max));
    _fetchProducts(refresh: true);
  }

  void toggleFilter({bool? cod, bool? instant, bool? points}) {
    final s = state.value ?? DiscoverState();
    state = AsyncData(
      s.copyWith(
        isSupportCod: cod,
        isSupportInstantDelivery: instant,
        isContainPoints: points,
      ),
    );
    _fetchProducts(refresh: true);
  }

  void setSort(String? sortBy, bool descending) {
    final s = state.value ?? DiscoverState();
    state = AsyncData(s.copyWith(sortBy: sortBy, sortDescending: descending));
    _fetchProducts(refresh: true);
  }

  void resetFilters() {
    final s = state.value ?? DiscoverState();
    state = AsyncData(
      DiscoverState(
        searchQuery: s.searchQuery, // Keep search
        selectedCategory: s.selectedCategory, // Keep category
        isLoading: true,
      ),
    );
    _fetchProducts(refresh: true);
  }
}

final discoverControllerProvider =
    AsyncNotifierProvider.autoDispose<DiscoverController, DiscoverState>(
      DiscoverController.new,
    );
