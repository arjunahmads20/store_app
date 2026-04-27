import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/product/domain/review.dart';

class ProductReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  ProductReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  ProductReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return ProductReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class ProductReviewsController extends StateNotifier<ProductReviewsState> {
  final Ref ref;
  final Product product;
  static const int _pageSize = 10;

  ProductReviewsController(this.ref, this.product)
    : super(ProductReviewsState(isLoading: true)) {
    // Initial fetch
    _fetchReviews(refresh: true);
  }

  Future<void> _fetchReviews({bool refresh = false}) async {
    // Prevent duplicate calls
    if (!refresh && (state.isLoading || state.isLoadingMore || !state.hasMore))
      return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        reviews: [],
        page: 1,
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final pageToFetch = refresh ? 1 : state.page + 1;

      final newReviews = await ref
          .read(productRepositoryProvider)
          .getReviews(
            product.parentProductId,
            page: pageToFetch,
            pageSize: _pageSize,
          );

      final hasMore = newReviews.length >= _pageSize;
      final currentReviews = refresh ? <Review>[] : state.reviews;

      if (refresh) {
        state = state.copyWith(
          isLoading: false,
          reviews: newReviews,
          page: 1,
          hasMore: hasMore,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          reviews: [...currentReviews, ...newReviews],
          page: pageToFetch,
          hasMore: hasMore,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void loadNextPage() {
    _fetchReviews(refresh: false);
  }

  void refresh() {
    _fetchReviews(refresh: true);
  }
}

final productReviewsControllerProvider = StateNotifierProvider.autoDispose
    .family<ProductReviewsController, ProductReviewsState, Product>((
      ref,
      product,
    ) {
      return ProductReviewsController(ref, product);
    });
