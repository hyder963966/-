import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'data/database.dart'; // استيراد مزود قاعدة البيانات
import 'data/models/drug.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [DrugSchema],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        // override للمزوّد المعرف في database.dart
        isarProvider.overrideWithValue(isar),
      ],
      child: const PharmacyApp(),
    ),
  );
}