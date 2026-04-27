import 'package:isar/isar.dart';

part 'drug.g.dart';

@collection
class Drug {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String barcode;

  final String name;
  final String genericName;
  final String dosageForm;
  final String therapeuticGroup;
  final double price;
  int quantity;
  final int reorderLevel;
  String? usage;
  String? imagePath;
  final DateTime createdAt;
  DateTime updatedAt;

  Drug({
    this.barcode = '',
    required this.name,
    this.genericName = '',
    required this.dosageForm,
    required this.therapeuticGroup,
    required this.price,
    this.quantity = 0,
    this.reorderLevel = 10,
    this.usage,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();
}