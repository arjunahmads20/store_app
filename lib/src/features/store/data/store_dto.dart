import 'package:store_app/src/features/store/domain/store.dart';

class StoreDto {
  final int id;
  final String name;
  final int? street;
  final int? village;
  final String? streetName;
  final String? villageName;
  final String? districtName;
  final String? lattitude;
  final String? longitude;

  StoreDto({
    required this.id,
    required this.name,
    this.street,
    this.village,
    this.streetName,
    this.villageName,
    this.districtName,
    this.lattitude,
    this.longitude,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) {
    return StoreDto(
      id: json['id'] as int,
      name: json['name'] as String,
      street: json['street'] as int?,
      village: json['village'] as int?,
      streetName: json['street_name'] as String?,
      villageName: json['village_name'] as String?,
      districtName: json['district_name'] as String?,
      lattitude: json['lattitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Store toDomain() {
    return Store(
      id: id.toString(),
      name: name,
      streetId: street,
      villageId: village,
      streetName: streetName,
      villageName: villageName,
      districtName: districtName,
      latitude: double.tryParse(lattitude ?? ''),
      longitude: double.tryParse(longitude ?? ''),
    );
  }
}
