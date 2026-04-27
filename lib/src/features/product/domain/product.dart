import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? productCategoryId;
  final String? size;
  final String? unit;
  final String? description;
  final double buyPrice;
  final double sellPrice;
  final bool isSupportInstantDelivery;
  final bool isSupportCod;
  final String? pictureUrl;
  final List<String>? tags;
  final DateTime datetimeAdded;

  final double rating;
  final int reviewCount;
  final String? discountLabel;
  final double? discountPercentage;

  final int stock;
  final int soldCount;
  final bool isFavorite;

  // Linking Fields
  final String parentProductId; // Global Product ID
  final String storeId;
  final String? categoryName; // Denormalized name for display
  final bool isFlashSale;
  final int pointEarned;

  const Product({
    required this.id,
    required this.name,
    this.productCategoryId,
    this.size,
    this.unit,
    this.description,
    this.buyPrice = 0,
    required this.sellPrice,
    this.isSupportInstantDelivery = false,
    this.isSupportCod = false,
    this.pictureUrl,
    this.tags,
    required this.datetimeAdded,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.discountLabel,
    this.discountPercentage,
    this.stock = 0,
    this.soldCount = 0,
    this.isFavorite = false,
    required this.parentProductId,
    required this.storeId,
    this.categoryName,
    this.isFlashSale = false,
    this.pointEarned = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    productCategoryId,
    size,
    unit,
    description,
    buyPrice,
    sellPrice,
    isSupportInstantDelivery,
    isSupportCod,
    pictureUrl,
    tags,
    datetimeAdded,
    rating,
    reviewCount,
    discountLabel,
    discountPercentage,
    stock,
    soldCount,
    isFavorite,
    parentProductId,
    storeId,
    categoryName,
    isFlashSale,
    pointEarned,
  ];
}
