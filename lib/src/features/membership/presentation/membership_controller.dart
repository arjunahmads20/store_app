import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:store_app/src/features/membership/data/membership_repository.dart';
import 'package:store_app/src/features/membership/domain/membership.dart';
import 'package:store_app/src/features/membership/domain/user_membership_model.dart';
import 'package:store_app/src/features/product/data/product_repository.dart';
import 'package:store_app/src/features/product/domain/product.dart';

class MembershipState {
  final UserMembership? userMembership;
  final List<Membership> memberships;
  final List<Product> productsWithPoints;
  final bool isLoading;

  MembershipState({
    this.userMembership,
    this.memberships = const [],
    this.productsWithPoints = const [],
    this.isLoading = false,
  });

  MembershipState copyWith({
    UserMembership? userMembership,
    List<Membership>? memberships,
    List<Product>? productsWithPoints,
    bool? isLoading,
  }) {
    return MembershipState(
      userMembership: userMembership ?? this.userMembership,
      memberships: memberships ?? this.memberships,
      productsWithPoints: productsWithPoints ?? this.productsWithPoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Helper to get current membership detail
  Membership? get currentMembershipDetail {
    if (userMembership == null) return null;
    try {
      return memberships.firstWhere((m) => m.id == userMembership!.membership);
    } catch (_) {
      return null;
    }
  }
}

class MembershipController extends StateNotifier<MembershipState> {
  final MembershipRepository _repository;
  final ProductRepository _productRepository;

  MembershipController(this._repository, this._productRepository)
    : super(MembershipState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final userMembership = await _repository.getUserMembership();
      final memberships = await _repository.getMemberships();

      // Use ProductRepository to get products with points directly
      final products = await _productRepository.getProducts(
        isContainPoints: true,
      );
      state = state.copyWith(
        userMembership: userMembership,
        memberships: memberships,
        productsWithPoints: products,
        isLoading: false,
      );
    } catch (e) {
      print("debug $e");
      state = state.copyWith(isLoading: false);
      // Handle error implicitly or add error state
    }
  }
}

final membershipControllerProvider =
    StateNotifierProvider.autoDispose<MembershipController, MembershipState>((
      ref,
    ) {
      return MembershipController(
        ref.watch(membershipRepositoryProvider),
        ref.watch(productRepositoryProvider),
      );
    });
