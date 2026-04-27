import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final int id;
  final String name;
  final double fee;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.fee,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      fee: double.tryParse(json['fee']?.toString() ?? '0') ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, fee];
}
