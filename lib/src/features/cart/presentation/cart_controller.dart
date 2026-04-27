import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/cart/data/cart_repository.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';

class CartController extends AsyncNotifier<Cart?> {
  @override
  FutureOr<Cart?> build() {
    return _fetchCart();
  }

  Future<Cart?> _fetchCart() async {
    final cart = await ref.read(cartRepositoryProvider).getCart();
    if (cart == null) {
      try {
        print("CartController: No cart found, creating new one...");
        return await ref.read(cartRepositoryProvider).createCart();
      } catch (e) {
        // If creation fails (e.g. network), just return null for now
        print("CartController: Auto-creation failed: $e");
        return null;
      }
    }
    return cart;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCart());
  }

  Future<bool> addToCart(String productId, int quantity) async {
    // Note: productId is the global product id not the id for ProductInStore instance
    var currentCart = state.value;
    if (currentCart == null) {
      // Attempt to create a cart for the new user
      try {
        currentCart = await ref.read(cartRepositoryProvider).createCart();
        // Manually update state so we have a valid cart immediately
        state = AsyncData(currentCart);
      } catch (e) {
        // If creation fails, log and return (UI will stay same)
        print("Failed to auto-create cart: $e");
        return false;
      }
    }

    // To implement optimistic updates or just loading state:
    // For simplicity, we just set loading and refresh.
    // Ideally, we'd add to the local list first.
    print(
      'CartController: Adding product $productId to cart ${currentCart!.id}',
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(cartRepositoryProvider)
          .addToCart(currentCart!.id, productId, quantity);
      print('CartController: Added to cart, fetching new state...');
      final newCart = await _fetchCart();
      print(
        'CartController: New state fetched. Items: ${newCart?.items.length}',
      );
      return newCart;
    });

    return !state.hasError;
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    final oldCart = state.value;
    if (oldCart == null) return;

    // 1. Optimistic Update
    final optimisticItems = oldCart.items.map((item) {
      if (item.id == itemId) return item.copyWith(quantity: quantity);
      return item;
    }).toList();
    final optimisticCart = oldCart.copyWith(items: optimisticItems);

    state = AsyncData(optimisticCart);

    // 2. Perform Request
    try {
      await ref
          .read(cartRepositoryProvider)
          .updateCartItem(oldCart.id, itemId, quantity: quantity);
      // Optional: Silent refresh to ensure sync
      // final freshCart = await _fetchCart();
      // if (freshCart != null) state = AsyncData(freshCart);
    } catch (e) {
      // Revert on failure
      state = AsyncData(oldCart);
      print("Update quantity failed: $e");
      // TODO: Show snackbar if possible, but we don't have context here easily without a listener
    }
  }

  Future<void> toggleCheck(int itemId, bool isChecked) async {
    final oldCart = state.value;
    if (oldCart == null) return;

    final optimisticItems = oldCart.items.map((item) {
      if (item.id == itemId) return item.copyWith(isChecked: isChecked);
      return item;
    }).toList();
    final optimisticCart = oldCart.copyWith(items: optimisticItems);

    state = AsyncData(optimisticCart);

    try {
      await ref
          .read(cartRepositoryProvider)
          .updateCartItem(oldCart.id, itemId, isChecked: isChecked);
    } catch (e) {
      state = AsyncData(oldCart);
      print("Toggle check failed: $e");
    }
  }

  Future<void> removeItem(int itemId) async {
    final oldCart = state.value;
    if (oldCart == null) return;

    final optimisticItems = oldCart.items.where((i) => i.id != itemId).toList();
    final optimisticCart = oldCart.copyWith(items: optimisticItems);

    state = AsyncData(optimisticCart);

    try {
      await ref.read(cartRepositoryProvider).removeFromCart(oldCart.id, itemId);
    } catch (e) {
      state = AsyncData(oldCart);
      print("Remove item failed: $e");
    }
  }

  Future<void> checkout() async {
    final currentCart = state.value;
    if (currentCart == null) return;

    state = const AsyncLoading(); // Checkout needs full loader as it navigates
    state = await AsyncValue.guard(() async {
      await ref.read(cartRepositoryProvider).checkout(currentCart.id);
      return _fetchCart();
    });
  }
}

final cartControllerProvider = AsyncNotifierProvider<CartController, Cart?>(
  CartController.new,
);
