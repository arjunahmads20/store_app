import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/constants/api_constants.dart';
import 'package:store_app/src/features/wallet/data/wallet_dto.dart';
import 'package:store_app/src/features/wallet/domain/wallet.dart';

abstract class WalletRepository {
  Future<Wallet?> getUserWallet();
}

class RemoteWalletRepository implements WalletRepository {
  final Dio _dio;

  RemoteWalletRepository(this._dio);

  @override
  Future<Wallet?> getUserWallet() async {
    try {
      final response = await _dio.get('/wallet/user-wallets/');
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return WalletDto.fromJson(data.first).toDomain();
      } else if (data is Map && data.containsKey('results')) {
        final list = data['results'] as List;
        if (list.isNotEmpty) {
          return WalletDto.fromJson(list.first).toDomain();
        }
      }
      return null;
    } catch (e) {
      // Return null or rethrow
      return null;
    }
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return RemoteWalletRepository(ref.watch(dioProvider));
});

final userWalletProvider = FutureProvider<Wallet?>((ref) {
  return ref.watch(walletRepositoryProvider).getUserWallet();
});
