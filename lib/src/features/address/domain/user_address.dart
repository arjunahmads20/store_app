import 'package:equatable/equatable.dart';

class UserAddress extends Equatable {
  final int id;
  final int userId;
  final int villageId;
  final int streetId;
  final String receiverName;
  final String receiverPhoneNumber;
  final Map<String, dynamic>? villageDetail;
  final Map<String, dynamic>? districtDetail;
  final Map<String, dynamic>? regencyDetail;
  final Map<String, dynamic>? provinceDetail;
  final Map<String, dynamic>? countryDetail;
  final Map<String, dynamic>? streetDetail;
  final String? otherDetails;
  final double latitude;
  final double longitude;
  final bool isMainAddress;
  final bool isOffice;

  const UserAddress({
    required this.id,
    required this.userId,
    required this.villageId,
    required this.streetId,
    required this.receiverName,
    required this.receiverPhoneNumber,
    this.villageDetail,
    this.districtDetail,
    this.regencyDetail,
    this.provinceDetail,
    this.countryDetail,
    this.streetDetail,
    this.otherDetails,
    required this.latitude,
    required this.longitude,
    required this.isMainAddress,
    required this.isOffice,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as int,
      userId: json['user'] as int,
      villageId: json['village'] as int,
      streetId: json['street'] as int,
      receiverName: json['receiver_name'] as String,
      receiverPhoneNumber: json['receiver_phone_number'] as String,
      villageDetail: json['village_detail'] as Map<String, dynamic>?,
      districtDetail: json['district_detail'] as Map<String, dynamic>?,
      regencyDetail: json['regency_detail'] as Map<String, dynamic>?,
      provinceDetail: json['province_detail'] as Map<String, dynamic>?,
      countryDetail: json['country_detail'] as Map<String, dynamic>?,
      streetDetail: json['street_detail'] as Map<String, dynamic>?,
      otherDetails: json['other_details'] as String?,
      latitude: double.tryParse(json['lattitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      isMainAddress: json['is_main_address'] as bool? ?? false,
      isOffice: json['is_office'] as bool? ?? false,
    );
  }

  String get fullAddress {
    final streetName = streetDetail?['name'] ?? 'Street $streetId';
    final villageName = villageDetail?['name'] ?? '';
    final districtName = districtDetail?['name'] ?? '';
    final regencyName = regencyDetail?['name'] ?? '';

    final parts = [streetName, villageName, districtName, regencyName];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    receiverName,
    isMainAddress,
    isOffice,
  ];
}
