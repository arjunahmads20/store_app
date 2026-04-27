import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/src/features/auth/data/user_dto.dart';

void main() {
  group('UserDto', () {
    test('fromJson parses correctly', () {
      final json = {
        "id": 1,
        "username": "08123456789",
        "first_name": "John",
        "last_name": "Doe",
        "email": "john@example.com",
        "phone_number": "08123456789",
        "role": "customer",
        "gender": "male",
        "date_of_birth": "1990-01-01",
        "avatar_url": "http://example.com/avatar.jpg",
        "status": "active",
        "daily_product_quota": 10,
        "id_store_work_on": null,
        "datetime_last_login": "2023-01-01T10:00:00Z",
        "datetime_joined": "2023-01-01T09:00:00Z"
      };

      final userDto = UserDto.fromJson(json);

      expect(userDto.id, 1);
      expect(userDto.firstName, "John");
      expect(userDto.lastName, "Doe");
      expect(userDto.email, "john@example.com");
      expect(userDto.phoneNumber, "08123456789");
      expect(userDto.dailyProductQuota, 10);
    });

    test('toDomain maps correctly', () {
       final json = {
        "id": 1,
        "username": "08123456789",
        "first_name": "John",
        "last_name": "Doe",
        "email": "john@example.com",
        "phone_number": "08123456789",
        "role": "customer",
        "status": "active",
      };
      
      final user = UserDto.fromJson(json).toDomain();
      
      expect(user.id, 1);
      expect(user.firstName, "John");
      expect(user.lastName, "Doe");
      expect(user.email, "john@example.com");
    });
  });
}
