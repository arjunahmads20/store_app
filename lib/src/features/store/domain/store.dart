import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final int? streetId;
  final int? villageId;
  final String? streetName;
  final String? villageName;
  final String? districtName;
  final double? latitude;
  final double? longitude;

  const Store({
    required this.id,
    required this.name,
    this.streetId,
    this.villageId,
    this.streetName,
    this.villageName,
    this.districtName,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    streetId,
    villageId,
    streetName,
    villageName,
    districtName,
    latitude,
    longitude,
  ];
}
