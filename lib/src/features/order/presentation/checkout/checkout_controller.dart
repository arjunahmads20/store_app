import 'package:riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/features/address/data/address_repository.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/cart/data/cart_repository.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:store_app/src/features/order/data/order_repository.dart';
import 'package:store_app/src/features/order/domain/delivery_type.dart';
import 'package:store_app/src/features/order/domain/order.dart'; // For API return
import 'package:store_app/src/features/order/domain/order_request.dart';
import 'package:store_app/src/features/order/presentation/order_controller.dart'; // For refreshing orders
import 'package:store_app/src/features/payment/data/payment_repository.dart';
import 'package:store_app/src/features/payment/domain/payment_method.dart';
import 'package:store_app/src/features/voucher/data/voucher_repository.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';

// --- State ---
class CheckoutState {
  final List<UserAddress> addresses;
  final List<DeliveryType> deliveryTypes;
  final List<PaymentMethod> paymentMethods;
  final List<UserVoucherOrder> vouchers;
  final Cart? cart;

  final UserAddress? selectedAddress;
  final DeliveryType? selectedDeliveryType;
  final PaymentMethod? selectedPaymentMethod;
  final UserVoucherOrder? selectedVoucher;
  final String? messageForShopper;

  final bool isPlacingOrder;
  final Order? order;

  CheckoutState({
    required this.addresses,
    required this.deliveryTypes,
    required this.paymentMethods,
    required this.vouchers,
    this.cart,
    this.selectedAddress,
    this.selectedDeliveryType,
    this.selectedPaymentMethod,
    this.selectedVoucher,
    this.messageForShopper,
    this.isPlacingOrder = false,
    this.order,
  });

  CheckoutState copyWith({
    List<UserAddress>? addresses,
    List<DeliveryType>? deliveryTypes,
    List<PaymentMethod>? paymentMethods,
    List<UserVoucherOrder>? vouchers,
    Cart? cart,
    UserAddress? selectedAddress,
    DeliveryType? selectedDeliveryType,
    PaymentMethod? selectedPaymentMethod,
    UserVoucherOrder? selectedVoucher,
    String? messageForShopper,
    bool? isPlacingOrder,
    Order? order,
  }) {
    return CheckoutState(
      addresses: addresses ?? this.addresses,
      deliveryTypes: deliveryTypes ?? this.deliveryTypes,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      vouchers: vouchers ?? this.vouchers,
      cart: cart ?? this.cart,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDeliveryType: selectedDeliveryType ?? this.selectedDeliveryType,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedVoucher: selectedVoucher ?? this.selectedVoucher,
      messageForShopper: messageForShopper ?? this.messageForShopper,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      order: order ?? this.order,
    );
  }

  // --- Computations ---
  double get subtotal => cart?.totalCost ?? 0.0;

  double get deliveryCost => selectedDeliveryType?.cost ?? 0.0;

  double get adminFee => selectedPaymentMethod?.fee ?? 0.0;

  bool isVoucherValid(UserVoucherOrder voucher) {
    if (voucher.voucherOrder == null) return false;
    if (voucher.isUsed) return false;

    final v = voucher.voucherOrder!;
    // Min Cost
    if (subtotal < v.minItemCost) return false;

    // Min items
    final totalItems =
        cart?.items.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;
    if (totalItems < v.minItemQuantity) return false;

    return true;
  }

  double get discountAmount {
    if (selectedVoucher == null || !isVoucherValid(selectedVoucher!))
      return 0.0;

    final voucher = selectedVoucher!.voucherOrder!;

    // Percentage Calculation
    double discount = subtotal * (voucher.discountPercentage / 100);

    // Max Nominal Cap
    if (voucher.maxNominalDiscount != null &&
        discount > voucher.maxNominalDiscount!) {
      discount = voucher.maxNominalDiscount!;
    }

    return discount;
  }

  double get total => subtotal + deliveryCost + adminFee - discountAmount;

  // Validation
  bool get canPlaceOrder =>
      selectedAddress != null &&
      selectedDeliveryType != null &&
      selectedPaymentMethod != null &&
      cart != null &&
      cart!.items.isNotEmpty;
}

// --- Controller ---
final checkoutControllerProvider =
    AsyncNotifierProvider.autoDispose<CheckoutController, CheckoutState>(
      CheckoutController.new,
    );

class CheckoutController extends AsyncNotifier<CheckoutState> {
  @override
  Future<CheckoutState> build() async {
    // Parallel Fetching
    final addressesFuture = ref.watch(userAddressesProvider.future);
    final deliveryTypesFuture = ref.watch(deliveryTypesProvider.future);
    final paymentMethodsFuture = ref.watch(paymentMethodsProvider.future);
    final vouchersFuture = ref.watch(userVouchersProvider.future);
    final cartFuture = ref
        .watch(cartRepositoryProvider)
        .getCart(isChecked: true);

    final results = await Future.wait([
      addressesFuture.then((v) => v as dynamic),
      deliveryTypesFuture.then((v) => v as dynamic),
      paymentMethodsFuture.then((v) => v as dynamic),
      vouchersFuture.then((v) => v as dynamic),
      cartFuture.then((v) => v as dynamic),
    ]);

    final addresses = results[0] as List<UserAddress>;
    final deliveryTypes = results[1] as List<DeliveryType>;
    final paymentMethods = results[2] as List<PaymentMethod>;
    final vouchers = results[3] as List<UserVoucherOrder>;
    final cart = results[4] as Cart?;

    // Default Selection Logic
    UserAddress? initialAddress;
    if (addresses.isNotEmpty) {
      initialAddress = addresses.firstWhere(
        (a) => a.isMainAddress,
        orElse: () => addresses.first,
      );
    }

    return CheckoutState(
      addresses: addresses,
      deliveryTypes: deliveryTypes,
      paymentMethods: paymentMethods,
      vouchers: vouchers,
      cart: cart,
      selectedAddress: initialAddress,
      // No defaults for delivery/payment to force user choice? Or set first.
      // Let's force choice for now, or set first if comfortable.
      selectedDeliveryType: null,
      selectedPaymentMethod: null,
      order: null,
    );
  }

  void refresh() {
    state = AsyncData(state.value!);
  }

  void selectAddress(UserAddress address) {
    state = AsyncData(state.value!.copyWith(selectedAddress: address));
  }

  void selectDeliveryType(DeliveryType type) {
    state = AsyncData(state.value!.copyWith(selectedDeliveryType: type));
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = AsyncData(state.value!.copyWith(selectedPaymentMethod: method));
  }

  void selectVoucher(UserVoucherOrder? voucher) {
    state = AsyncData(state.value!.copyWith(selectedVoucher: voucher));
  }

  void updateMessage(String message) {
    state = AsyncData(state.value!.copyWith(messageForShopper: message));
  }

  Future<void> placeOrder() async {
    final currentState = state.value;
    if (currentState == null || !currentState.canPlaceOrder) return;

    state = AsyncData(currentState.copyWith(isPlacingOrder: true));

    try {
      final request = OrderRequest(
        storeId:
            int.tryParse(
              currentState.cart?.items.firstOrNull?.product.storeId ?? '',
            ) ??
            1,
        addressId: currentState.selectedAddress!.id,
        deliveryTypeId: currentState.selectedDeliveryType!.id,
        paymentMethodId: currentState.selectedPaymentMethod!.id,
        userVoucherOrderId: currentState.selectedVoucher?.id,
        messageForShopper: currentState.messageForShopper,
        isOnlineOrder: true,
      );

      final order = await ref
          .read(orderRepositoryProvider)
          .createOrder(request);
      state = AsyncData(currentState.copyWith(order: order));
      // Refresh Orders List
      ref.invalidate(orderControllerProvider);
      // Ideally refresh Cart too (as it should be empty now)
      ref.invalidate(cartControllerProvider);
      // Refresh User data to reflect quota and point changes
      await ref.read(authControllerProvider.notifier).refreshUser();

      // Navigate or Success Callback handled by UI listener
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      // Reset loading if we didn't navigate away immediately (Error case)
      if (state.hasError) {
        // If error, we might want to keep the old state + error.
        // AsyncError replaces data. StateNotifier logic is tricky here.
        // Best to use Side Effects via listener in UI.
      } else {
        // Success.
      }
    }
  }
}
