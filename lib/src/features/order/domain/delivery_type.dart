import 'package:equatable/equatable.dart';

class DeliveryType extends Equatable {
  final int id;
  final String name;
  final double cost;
  final double? discount;

  const DeliveryType({
    required this.id,
    required this.name,
    required this.cost,
    this.discount,
  });

  factory DeliveryType.fromJson(Map<String, dynamic> json) {
    return DeliveryType(
      id: json['id'] as int,
      name: json['name'] as String,
      cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      discount: json['type'] != null
          ? double.tryParse(json['discount']?.toString() ?? '0')
          : 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, cost, discount];
}
