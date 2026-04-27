import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/src/features/product/data/flashsale_dto.dart';
import 'package:store_app/src/features/product/domain/flashsale.dart';

void main() {
  group('Flashsale Domain Tests', () {
    test('isActive returns true for current date inside range', () {
      final now = DateTime.now();
      final flashsale = Flashsale(
        id: '1',
        name: 'Test',
        startDateTime: now.subtract(const Duration(hours: 1)),
        endDateTime: now.add(const Duration(hours: 1)),
      );
      expect(flashsale.isActive, true);
    });

    test('isActive returns false for future date', () {
      final now = DateTime.now();
      final flashsale = Flashsale(
        id: '1',
        name: 'Test',
        startDateTime: now.add(const Duration(hours: 1)),
        endDateTime: now.add(const Duration(hours: 2)),
      );
      expect(flashsale.isActive, false);
    });

    test('timeRemaining calculates correctly', () {
      final now = DateTime.now();
      final end = now.add(const Duration(hours: 1));
      final flashsale = Flashsale(
        id: '1',
        name: 'Test',
        startDateTime: now.subtract(const Duration(hours: 1)),
        endDateTime: end,
      );
      
      final remaining = flashsale.timeRemaining;
      // Allow small difference due to execution time
      expect(remaining.inMinutes, closeTo(60, 1)); 
    });
  });

  group('FlashsaleDto Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Sale',
        'datetime_started': '2023-01-01T10:00:00Z',
        'datetime_ended': '2023-01-02T10:00:00Z',
      };
      final dto = FlashsaleDto.fromJson(json);
      expect(dto.id, 1);
      expect(dto.name, 'Sale');
      expect(dto.startDateTime, '2023-01-01T10:00:00Z');
    });

    test('toDomain converts correctly', () {
      final dto = FlashsaleDto(
        id: 1, 
        name: 'Sale', 
        startDateTime: '2023-01-01T10:00:00Z', 
        endDateTime: '2023-01-02T10:00:00Z'
      );
      final domain = dto.toDomain();
      expect(domain.id, '1');
      expect(domain.startDateTime, DateTime.utc(2023, 1, 1, 10, 0, 0));
    });
  });
}
