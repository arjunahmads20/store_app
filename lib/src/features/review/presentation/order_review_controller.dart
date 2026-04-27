import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:store_app/src/features/review/data/review_repository.dart';
import 'package:store_app/src/features/review/domain/order_review.dart';
import 'package:store_app/src/features/review/domain/product_review.dart';

class ReviewData {
  int rate;
  String comment;
  ReviewData({this.rate = 5, this.comment = ""});
}

class OrderReviewState {
  final bool isLoading;
  final bool isSubmitted;
  final String? error;

  // For viewing existing reviews
  final OrderReview? existingOrderReview;
  final List<ProductInOrderReview?> existingProductReviews;

  OrderReviewState({
    this.isLoading = false,
    this.isSubmitted = false,
    this.error,
    this.existingOrderReview,
    this.existingProductReviews = const [],
  });

  OrderReviewState copyWith({
    bool? isLoading,
    bool? isSubmitted,
    String? error,
    OrderReview? existingOrderReview,
    List<ProductInOrderReview?> existingProductReviews = const [],
  }) {
    return OrderReviewState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error:
          error, // Nullable, so if passed as null (explicitly logic needed) but here standard copyWith key is fine
      existingOrderReview: existingOrderReview ?? this.existingOrderReview,
      existingProductReviews:
          existingProductReviews ?? this.existingProductReviews,
    );
  }
}

class OrderReviewController extends StateNotifier<OrderReviewState> {
  final ReviewRepository _repository;

  OrderReviewController(this._repository) : super(OrderReviewState());

  Future<void> submitReview({
    required int orderId,
    required int orderRate,
    required String orderComment,
    required Map<int, ReviewData> productReviews, // Key: ProductInOrderId
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Submit Order Review
      await _repository.submitOrderReview(orderId, orderRate, orderComment);

      // 2. Submit Product Reviews (Parallel)
      final productFutures = productReviews.entries.map((entry) {
        return _repository.submitProductReview(
          entry.key,
          entry.value.rate,
          entry.value.comment,
        );
      });
      await Future.wait(productFutures);

      state = state.copyWith(isLoading: false, isSubmitted: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchReviews(int orderId, List<int> productInOrderIds) async {
    state = state.copyWith(isLoading: true);
    try {
      final orderReview = await _repository.getOrderReview(orderId);

      final productReviewFutures = productInOrderIds.map(
        (id) => _repository.getProductReview(id),
      );
      final productReviewsLists = await Future.wait(productReviewFutures);
      final allProductReviews = productReviewsLists;

      state = state.copyWith(
        isLoading: false,
        existingOrderReview: orderReview,
        existingProductReviews: allProductReviews,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final orderReviewControllerProvider =
    StateNotifierProvider.autoDispose<OrderReviewController, OrderReviewState>((
      ref,
    ) {
      return OrderReviewController(ref.watch(reviewRepositoryProvider));
    });
