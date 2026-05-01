import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/product/domain/product_category.dart';

class ProductCategoryDto {
  final int id;
  final String name;
  final String? iconUrl;

  ProductCategoryDto({required this.id, required this.name, this.iconUrl});

  factory ProductCategoryDto.fromJson(Map<String, dynamic> json) {
    return ProductCategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
    );
  }

  ProductCategory toDomain() {
    return ProductCategory(id: id.toString(), name: name, iconUrl: iconUrl);
  }
}

class ProductDto {
  final int id;
  final int productId; // Reference to global product ID
  final String productName;
  final String? productDescription,
  final String productPrice; // String from API
  final String? productPicture;
  final int? storeId;
  final Map<String, dynamic>? flashsaleInfo;
  final Map<String, dynamic>? category;
  final String? productTags;
  final int? stock;
  final int? soldCount;
  final bool? isFavorite;
  final Map<String, dynamic>? discountInfo;
  final Map<String, dynamic>? rating;
  final int? pointEarned;

  ProductDto({
    required this.id,
    required this.productId,
    required this.productName,
    this.productDescription,
    required this.productPrice,
    this.productPicture,
    this.productTags,
    this.stock,
    this.soldCount,
    this.isFavorite,
    this.discountInfo,
    this.rating,
    this.storeId,
    this.flashsaleInfo,
    this.category,
    this.pointEarned,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      productId: json['product'] as int, // This is the Global Product ID
      productName: json['product_name'] as String,
      productDescription: json['product_description'] as String?,
      productPrice: json['product_price']
          .toString(), // Handle both String and num
      productPicture: json['product_picture'] as String?,
      productTags: json['product_tags'] as String?,
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse(json['stock'].toString()),
      soldCount: json['sold_count'] is int
          ? json['sold_count'] as int
          : int.tryParse(json['sold_count'].toString()),
      isFavorite: json['is_favorite'] as bool?,
      discountInfo: json['discount_info'] as Map<String, dynamic>?,
      rating: json['rating'] as Map<String, dynamic>?,
      storeId: json['store'] as int?,
      flashsaleInfo: json['flashsale_info'] as Map<String, dynamic>?,
      category: json['category'] as Map<String, dynamic>?,
      pointEarned: json['point_earned'] as int?,
    );
  }

  factory ProductDto.fromGlobalJson(Map<String, dynamic> json) {
    return ProductDto(
      id: 0, // ID not relevant for Global Product context in Order view
      productId: json['id'] as int,
      productName: json['name'] as String,   
      productDescription: json['product_description'] as String?,
      productPrice: json['sell_price'].toString(),
      productPicture: json['picture_url'] as String?,

      // Map other available fields if any, defaults for others
    );
  }

  /// Converts this DTO to the [Product] domain entity.
  ///
  /// This method encapsulates critical business logic for price calculation and data cleaning:
  ///
  /// 1. **Price Calculation**:
  ///    - It parses the `productPrice` (String) to a double base price.
  ///    - It checks for **Flash Sale** discounts first (Priority 1). If active, it applies the percentage off.
  ///    - If no Flash Sale, it checks for **Regular Discounts** (Priority 2) from `discountInfo`.
  ///    - Sets `sellPrice` to the final calculated price and `buyPrice` to the original base price.
  ///
  /// 2. **Data Parsing & Cleaning**:
  ///    - Parses deeply nested maps (`rating`, `flashsaleInfo`, `discountInfo`) into flat fields.
  ///    - Safely converts types (e.g., String to double/int) to prevent runtime crashes.
  ///    - Splits comma-separated tags into a `List<String>`.
  ///    - valid defaults are provided for null fields (e.g., `stock: 0`, `isFavorite: false`).
  Product toDomain() {
    // Parse Base Price
    final double price = double.tryParse(productPrice) ?? 0.0;

    String? label;
    double? discountPct;
    double finalSellPrice = price;
    bool isFlashSaleActive = false;

    // 1. Check Flash Sale Info FIRST (Priority)
    if (flashsaleInfo != null) {
      final fsDiscount = flashsaleInfo!['discount_percentage'];
      if (fsDiscount != null) {
        discountPct = double.tryParse(fsDiscount.toString());
        // If valid flash sale discount, apply it
        if (discountPct != null && discountPct > 0) {
          finalSellPrice = price * (1 - (discountPct / 100));
          label = "Flash Sale"; // Or flashsaleInfo!['name']
          isFlashSaleActive = true;
        }
      }
    }

    // 2. If NO Flash Sale applied, check Regular Discount
    if (!isFlashSaleActive && discountInfo != null) {
      label = discountInfo!['label']?.toString();
      final pctValue = discountInfo!['percentage'];
      if (pctValue != null) {
        final regularPct = double.tryParse(pctValue.toString());
        if (regularPct != null && regularPct > 0) {
          discountPct = regularPct;
          finalSellPrice = price * (1 - (regularPct / 100));
        }
      }
    }

    // Parse Rating
    double rate = 0.0;
    int reviews = 0;
    if (rating != null) {
      rate = (rating!['average_rate'] as num?)?.toDouble() ?? 0.0;
      reviews = (rating!['review_count'] as int?) ?? 0;
    }

    // Parse Tags
    List<String> tagsList = [];
    if (productTags != null && productTags!.isNotEmpty) {
      tagsList = productTags!.split(',').map((e) => e.trim()).toList();
    }

    return Product(
      id: id.toString(), // ProductInStore ID
      name: productName,
      description: productDescription,
      sellPrice: finalSellPrice,
      buyPrice: price, // Original/Base Price
      pictureUrl: productPicture,
      datetimeAdded: DateTime.now(),
      rating: rate,
      reviewCount: reviews,
      discountLabel: label,
      discountPercentage: discountPct,
      tags: tagsList,
      stock: stock ?? 0,
      soldCount: soldCount ?? 0,
      isFavorite: isFavorite ?? false,
      parentProductId: productId.toString(),
      storeId: storeId.toString(),
      isFlashSale: isFlashSaleActive,
      categoryName: category != null ? category!['name'] as String? : null,
      pointEarned: pointEarned ?? 0,
    );
  }
}
