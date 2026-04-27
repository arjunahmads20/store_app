import 'package:store_app/src/features/product/domain/flashsale.dart';

class FlashsaleDto {
  final int id;
  final String name;
  final String startDateTime;
  final String endDateTime;
  final String? bannerUrl;

  FlashsaleDto({
    required this.id,
    required this.name,
    required this.startDateTime,
    required this.endDateTime,
    this.bannerUrl,
  });

  factory FlashsaleDto.fromJson(Map<String, dynamic> json) {
    return FlashsaleDto(
      id: json['id'] as int,
      name: json['name'] as String,
      startDateTime: json['datetime_started'] as String,
      endDateTime: json['datetime_ended'] as String,
      bannerUrl: json['banner_url'] as String?,
    );
  }

  Flashsale toDomain() {
    return Flashsale(
      id: id.toString(),
      name: name,
      startDateTime: DateTime.parse(startDateTime),
      endDateTime: DateTime.parse(endDateTime),
      bannerUrl: bannerUrl,
    );
  }
}
