import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:store_app/src/features/cart/data/cart_dto.dart';
import 'package:store_app/src/features/cart/data/cart_repository.dart';
import 'package:store_app/src/features/cart/domain/cart.dart';
import 'package:store_app/src/features/cart/presentation/cart_controller.dart';
import 'package:store_app/src/features/product/domain/product.dart';

import 'cart_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  group('CartDto Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'user': 101,
      };
      final dto = CartDto.fromJson(json);
      expect(dto.id, 1);
      expect(dto.user, 101);
    });

    test('CartItemDto fromJson parses correctly', () {
      final json = {
        'id': 5,
        'user_cart': 1,
        'product': 50,
        'quantity': 2,
        'is_checked': false,
      };
      final dto = CartItemDto.fromJson(json);
      expect(dto.id, 5);
      expect(dto.quantity, 2);
      expect(dto.isChecked, false);
      expect(dto.productData, 50);
    });
  });

  group('CartController Tests', () {
    late MockCartRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockCartRepository();
      container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    test('build fetches cart', () async {
      final emptyCart = Cart(id: 1, userId: 1, items: []);
      when(mockRepo.getCart()).thenAnswer((_) async => emptyCart);

      final controller = container.read(cartControllerProvider.notifier);
      // Trigger build
      final state = container.read(cartControllerProvider);
      
      // Wait for async
      await Future.delayed(Duration.zero);
      
      verify(mockRepo.getCart()).called(1);
      expect(container.read(cartControllerProvider).value, emptyCart);
    });

    test('addToCart calls repository and refreshes', () async {
      final initialCart = Cart(id: 1, userId: 1, items: []);
      final updatedCart = Cart(id: 1, userId: 1, items: [
        CartItem(id: 10, product: Product(id: '1', name: 'Test', sellPrice: 100, datetimeAdded: DateTime.now()), quantity: 1)
      ]);

      // Stub getCart to return distinct values on subsequent calls
      int callCount = 0;
      when(mockRepo.getCart()).thenAnswer((_) async {
        callCount++;
        return callCount == 1 ? initialCart : updatedCart;
      });
      when(mockRepo.addToCart(any, any, any)).thenAnswer((_) async => {});

      // Initialize
      await container.read(cartControllerProvider.future);

      // Action
      await container.read(cartControllerProvider.notifier).addToCart('1', 1);

      // Verify
      verify(mockRepo.addToCart(1, '1', 1)).called(1);
      // Should have refreshed
      expect(container.read(cartControllerProvider).value, updatedCart);
    });

    test('updateQuantity calls repository with cartId', () async {
      final cart = Cart(id: 1, userId: 1, items: [
        CartItem(id: 10, product: Product(id: '1', name: 'Test', sellPrice: 100, datetimeAdded: DateTime.now()), quantity: 1)
      ]);

      when(mockRepo.getCart()).thenAnswer((_) async => cart);
      when(mockRepo.updateCartItem(any, any, quantity: anyNamed('quantity'))).thenAnswer((_) async => {});

      await container.read(cartControllerProvider.future);
      await container.read(cartControllerProvider.notifier).updateQuantity(10, 2);

      verify(mockRepo.updateCartItem(1, 10, quantity: 2)).called(1);
    });

    test('removeItem calls repository with cartId', () async {
      final cart = Cart(id: 1, userId: 1, items: [
        CartItem(id: 10, product: Product(id: '1', name: 'Test', sellPrice: 100, datetimeAdded: DateTime.now()), quantity: 1)
      ]);

      when(mockRepo.getCart()).thenAnswer((_) async => cart);
      when(mockRepo.removeFromCart(any, any)).thenAnswer((_) async => {});

      await container.read(cartControllerProvider.future);
      await container.read(cartControllerProvider.notifier).removeItem(10);

      verify(mockRepo.removeFromCart(1, 10)).called(1);
    });
  });
}
