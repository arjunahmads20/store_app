import 'package:store_app/src/features/wallet/domain/wallet.dart';

class WalletDto {
  final String id;
  final double? balance;
  final String? accountNumber;
  final String? pinNumber;

  WalletDto({
    required this.id,
    this.balance,
    this.accountNumber,
    this.pinNumber,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      id: json['id'].toString(),
      balance: double.tryParse(json['balance'].toString()),
      accountNumber: json['account_number'],
      pinNumber: json['pin_number'],
    );
  }

  Wallet toDomain() {
    return Wallet(
      id: id,
      balance: balance ?? 0.0,
      accountNumber: accountNumber ?? '',
      pinNumber: pinNumber ?? '',
    );
  }
}
