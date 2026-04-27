import 'package:equatable/equatable.dart';

class VoucherOrder extends Equatable {
  final int id;
  final String name;
  final String sourceType;
  final int minItemQuantity;
  final double minItemCost;
  final double discountPercentage;
  final double? maxNominalDiscount;
  final String? description;
  final String? imgUrl;
  final DateTime? datetimeStarted;
  final DateTime? datetimeExpiry;

  const VoucherOrder({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.minItemQuantity,
    required this.minItemCost,
    required this.discountPercentage,
    this.maxNominalDiscount,
    this.description,
    this.imgUrl,
    this.datetimeStarted,
    this.datetimeExpiry,
  });

  factory VoucherOrder.fromJson(Map<String, dynamic> json) {
    return VoucherOrder(
      id: json['id'] as int,
      name: json['name'] as String,
      sourceType: json['source_type'] as String,
      minItemQuantity: json['min_item_quantity'] as int? ?? 0,
      minItemCost:
          double.tryParse(json['min_item_cost']?.toString() ?? '0') ?? 0.0,
      discountPercentage:
          double.tryParse(json['discount_precentage']?.toString() ?? '0') ??
          0.0,
      maxNominalDiscount: json['max_nominal_discount'] != null
          ? double.tryParse(json['max_nominal_discount'].toString())
          : null,
      description: json['description'] as String?,
      imgUrl: json['img_url'] as String?,
      datetimeStarted: json['datetime_started'] != null
          ? DateTime.tryParse(json['datetime_started'] as String)
          : null,
      datetimeExpiry: json['datetime_expiry'] != null
          ? DateTime.tryParse(json['datetime_expiry'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    discountPercentage,
    minItemCost,
    maxNominalDiscount,
  ];
}

class UserVoucherOrder extends Equatable {
  final int id;
  final int userId;
  final int voucherOrderId; // Or expanded object
  final bool isUsed;
  final VoucherOrder? voucherOrder; // For convenience if expanded

  const UserVoucherOrder({
    required this.id,
    required this.userId,
    required this.voucherOrderId,
    required this.isUsed,
    this.voucherOrder,
  });

  factory UserVoucherOrder.fromJson(Map<String, dynamic> json) {
    // Check if voucher_order is int or map
    VoucherOrder? voucher;
    int vId;
    if (json['voucher_order'] is Map) {
      voucher = VoucherOrder.fromJson(json['voucher_order']);
      vId = voucher.id;
    } else {
      vId = json['voucher_order'] as int;
    }

    return UserVoucherOrder(
      id: json['id'] as int,
      userId: json['user'] as int,
      voucherOrderId: vId,
      isUsed: json['is_used'] as bool? ?? false,
      voucherOrder: voucher,
    );
  }

  @override
  List<Object?> get props => [id, userId, voucherOrderId, isUsed];
}
