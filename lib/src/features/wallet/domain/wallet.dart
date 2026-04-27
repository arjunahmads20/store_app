import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final double balance;
  final String accountNumber;
  final String pinNumber;

  const Wallet({
    required this.id,
    required this.balance,
    required this.accountNumber,
    required this.pinNumber,
  });

  @override
  List<Object?> get props => [id, balance, accountNumber, pinNumber];

  String get formattedBalance {
    // Hardcoded currency for now as API doesn't provide it
    return 'Rp ${balance.toStringAsFixed(0)}';
  }
}
