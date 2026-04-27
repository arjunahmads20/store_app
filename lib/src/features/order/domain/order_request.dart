class OrderRequest {
  final int storeId;
  final int addressId;
  final int deliveryTypeId;
  final int paymentMethodId;
  final int? userVoucherOrderId;
  final String?
  messageForShopper; // API Schema says 'message_for_shopper', ERD says 'message_for_driver'.
  // Schema (4.3 Place Order) says 'message_for_shopper'. Order Details says 'message_for_driver'.
  // I will use 'message_for_shopper' for mapping to request.
  final bool isOnlineOrder;

  OrderRequest({
    required this.storeId,
    required this.addressId,
    required this.deliveryTypeId,
    required this.paymentMethodId,
    this.userVoucherOrderId,
    this.messageForShopper,
    this.isOnlineOrder = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'address_id': addressId,
      'delivery_type_id': deliveryTypeId,
      'payment_method_id': paymentMethodId,
      if (userVoucherOrderId != null)
        'user_voucher_order_id': userVoucherOrderId,
      if (messageForShopper != null) 'message_for_shopper': messageForShopper,
      'is_online_order': isOnlineOrder,
    };
  }
}
