import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'models/drug.dart';

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

final isarInstanceProvider = Provider<Isar>((ref) {
  return ref.watch(isarProvider);
});