import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;

  const ProductCategory({required this.id, required this.name, this.iconUrl});

  @override
  List<Object?> get props => [id, name, iconUrl];
}
