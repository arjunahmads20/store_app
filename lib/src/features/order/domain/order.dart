import 'package:equatable/equatable.dart';
import 'package:store_app/src/features/product/data/product_dto.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/order/domain/delivery_type.dart';
import 'package:store_app/src/features/voucher/domain/voucher_models.dart';

class Order extends Equatable {
  final int id;
  final int storeId;
  final int customerId;
  final int addressId;
  final DeliveryType? deliveryType;
  final List<ProductInOrder> products;
  final double totalProductCost;
  final double totalCost;
  final int pointEarnedTotal;
  final String status;
  final bool isOnlineOrder;
  final String? messageForDriver;
  final DateTime datetimeCreated;
  final DateTime datetimeProcessed;
  final DateTime datetimeShipped;
  final DateTime datetimeCancelled;
  final DateTime datetimeFinished;
  final PaymentInfo? paymentInfo;
  final VoucherOrder? voucher;
  final String? transactionRedirectUrl;

  const Order({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.addressId,
    this.deliveryType,
    required this.products,
    required this.totalProductCost,
    required this.totalCost,
    required this.pointEarnedTotal,
    required this.status,
    required this.isOnlineOrder,
    this.messageForDriver,
    required this.datetimeCreated,
    required this.datetimeProcessed,
    required this.datetimeShipped,
    required this.datetimeCancelled,
    required this.datetimeFinished,
    this.paymentInfo,
    this.voucher,
    this.transactionRedirectUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      storeId: json['store'] as int,
      customerId: json['customer'] as int,
      addressId: json['address'] as int,
      deliveryType: json['delivery_type'] != null
          ? DeliveryType.fromJson(json['delivery_type'])
          : null,
      products:
          (json['products'] as List?)
              ?.map((e) => ProductInOrder.fromJson(e))
              .toList() ??
          [],
      totalProductCost:
          double.tryParse(json['total_product_cost']?.toString() ?? '0') ?? 0.0,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0.0,
      pointEarnedTotal: json['point_earned_total'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      isOnlineOrder: json['is_online_order'] as bool? ?? false,
      messageForDriver: json['message_for_driver'] as String?,
      datetimeCreated: DateTime.parse(json['datetime_created'] as String),
      datetimeProcessed: json['datetime_processed'] != null
          ? DateTime.parse(json['datetime_processed'] as String)
          : DateTime.parse("1970-01-01"),
      datetimeShipped: json['datetime_shipped'] != null
          ? DateTime.parse(json['datetime_shipped'] as String)
          : DateTime.parse("1970-01-01"),
      datetimeCancelled: json['datetime_cancelled'] != null
          ? DateTime.parse(json['datetime_cancelled'] as String)
          : DateTime.parse("1970-01-01"),
      datetimeFinished: json['datetime_finished'] != null
          ? DateTime.parse(json['datetime_finished'] as String)
          : DateTime.parse("1970-01-01"),
      paymentInfo: json['payment_info'] != null
          ? PaymentInfo.fromJson(json['payment_info'])
          : null,
      voucher:
          (json['payment_info'] != null &&
              json['payment_info']['user_voucher_order'] != null &&
              json['payment_info']['user_voucher_order']['voucher_order'] !=
                  null)
          ? VoucherOrder.fromJson(
              json['payment_info']['user_voucher_order']['voucher_order'],
            )
          : null,
      transactionRedirectUrl:
          (json['payment_info'] != null &&
              json['payment_info']['transaction_redirect_url'] != null)
          ? json['payment_info']['transaction_redirect_url'] as String?
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    totalCost,
    pointEarnedTotal,
    datetimeCreated,
    transactionRedirectUrl,
  ];
}

class ProductInOrder extends Equatable {
  final int id;
  final Product product;
  final int quantity;
  final int pointEarned;
  final int? productInStoreInFlashsaleId;
  final int? productInStoreInProductInStoreDiscountId;
  final double flashsaleDiscountPercentage;
  final double productDiscountPercentage;

  const ProductInOrder({
    required this.id,
    required this.product,
    required this.quantity,
    required this.pointEarned,
    this.productInStoreInFlashsaleId,
    this.productInStoreInProductInStoreDiscountId,
    this.flashsaleDiscountPercentage = 0.0,
    this.productDiscountPercentage = 0.0,
  });

  factory ProductInOrder.fromJson(Map<String, dynamic> json) {
    return ProductInOrder(
      id: json['id'] as int,
      product: ProductDto.fromGlobalJson(json['product']).toDomain(),
      quantity: json['quantity'] as int? ?? 0,
      pointEarned: json['point_earned'] as int? ?? 0,
      productInStoreInFlashsaleId:
          json['product_in_store_in_flashsale'] as int?,
      productInStoreInProductInStoreDiscountId:
          json['product_in_store_in_product_in_store_discount'] as int?,
      flashsaleDiscountPercentage:
          double.tryParse(
            json['flashsale_discount_percentage']?.toString() ?? '0',
          ) ??
          0.0,
      productDiscountPercentage:
          double.tryParse(
            json['product_discount_percentage']?.toString() ?? '0',
          ) ??
          0.0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    product,
    quantity,
    pointEarned,
    productInStoreInFlashsaleId,
    productInStoreInProductInStoreDiscountId,
    flashsaleDiscountPercentage,
    productDiscountPercentage,
  ];
}

class PaymentInfo extends Equatable {
  final int id;
  final String? accountNumber;
  final String status;
  final PaymentMethodInfo? paymentMethod;

  const PaymentInfo({
    required this.id,
    this.accountNumber,
    required this.status,
    this.paymentMethod,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] as int? ?? 0,
      accountNumber: json['account_number'] as String?,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] != null
          ? PaymentMethodInfo.fromJson(json['payment_method'])
          : null,
    );
  }

  @override
  List<Object?> get props => [accountNumber, status, paymentMethod];
}

class PaymentMethodInfo extends Equatable {
  final int id;
  final String name;
  final double discountedFee;

  const PaymentMethodInfo({
    required this.id,
    required this.name,
    required this.discountedFee,
  });

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      discountedFee:
          double.tryParse(json['discounted_fee']?.toString() ?? '0') ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, discountedFee];
}
