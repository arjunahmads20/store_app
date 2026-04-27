import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';
import 'package:store_app/src/features/address/domain/region_models.dart';

class AddressRepository {
  final Dio _dio;

  AddressRepository(this._dio);

  Future<List<UserAddress>> getUserAddresses() async {
    try {
      final response = await _dio.get(ApiConstants.userAddresses);
      final data = response.data;
      List list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'];
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      return list.map((e) => UserAddress.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load addresses: $e');
    }
  }

  Future<UserAddress> getAddress(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.userAddresses}$id/');
      return UserAddress.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load address: $e');
    }
  }

  Future<void> setMainAddress(int id) async {
    try {
      // Assuming a patch/post endpoint to set as main.
      // Often /user-addresses/{id}/set_main/ or PATCH { is_main_address: true }
      // The schema didn't explicit show an action, but standard REST would probably be PATCH.
      // However, usually setting main affects others (toggles them off).
      // Let's try PATCH for now as it's safest for a partial update.
      await _dio.patch(
        '${ApiConstants.userAddresses}$id/',
        data: {'is_main_address': true},
      );
    } catch (e) {
      throw Exception('Failed to set main address: $e');
    }
  }

  // --- Region Methods ---

  Future<List<Province>> getProvinces() async {
    try {
      final response = await _dio.get('/address/provinces/');
      return (response.data['results'] as List)
          .map((e) => Province.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load provinces: $e');
    }
  }

  Future<List<RegencyMunicipality>> getRegencies(int provinceId) async {
    try {
      final response = await _dio.get(
        '/address/regency-municipalities/',
        queryParameters: {'province': provinceId},
      );
      return (response.data['results'] as List)
          .map((e) => RegencyMunicipality.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load regencies: $e');
    }
  }

  Future<List<District>> getDistricts(int regencyId) async {
    try {
      final response = await _dio.get(
        '/address/districts/',
        queryParameters: {'regency_municipality': regencyId},
      );
      return (response.data['results'] as List)
          .map((e) => District.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load districts: $e');
    }
  }

  Future<List<Village>> getVillages(int districtId) async {
    try {
      final response = await _dio.get(
        '/address/villages/',
        queryParameters: {'district': districtId},
      );
      return (response.data['results'] as List)
          .map((e) => Village.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load villages: $e');
    }
  }

  Future<List<Street>> getStreets(int villageId) async {
    try {
      final response = await _dio.get('/address/streets/');
      return (response.data['results'] as List)
          .map((e) => Street.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load streets: $e');
    }
  }

  Future<void> createAddress({
    required String receiverName,
    required String receiverPhoneNumber,
    required int streetId,
    required int villageId,
    required double latitude,
    required double longitude,
    required bool isOffice,
    required bool isMainAddress,
    String? otherDetails,
  }) async {
    try {
      await _dio.post(
        ApiConstants.userAddresses,
        data: {
          'receiver_name': receiverName,
          'receiver_phone_number': receiverPhoneNumber,
          'street': streetId,
          'village': villageId,
          'lattitude': latitude,
          'longitude': longitude,
          'is_office': isOffice,
          'is_main_address': isMainAddress,
          'other_details': otherDetails,
        },
      );
    } catch (e) {
      throw Exception("Failed to create address: $e");
    }
  }

  Future<void> updateAddress({
    required int id,
    required String receiverName,
    required String receiverPhoneNumber,
    required int streetId,
    required int villageId,
    required double latitude,
    required double longitude,
    required bool isOffice,
    required bool isMainAddress,
    String? otherDetails,
  }) async {
    try {
      await _dio.put(
        '${ApiConstants.userAddresses}$id/',
        data: {
          'receiver_name': receiverName,
          'receiver_phone_number': receiverPhoneNumber,
          'street': streetId,
          'village': villageId,
          'lattitude': latitude,
          'longitude': longitude,
          'is_office': isOffice,
          'is_main_address': isMainAddress,
          'other_details': otherDetails,
        },
      );
    } catch (e) {
      throw Exception("Failed to update address: $e");
    }
  }
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(dioProvider));
});

final userAddressesProvider = FutureProvider<List<UserAddress>>((ref) async {
  return ref.watch(addressRepositoryProvider).getUserAddresses();
});
