import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database.dart';
import '../models/drug.dart';

final drugRepoProvider = Provider<DrugRepository>((ref) {
  final isar = ref.watch(isarInstanceProvider);
  return DrugRepository(isar);
});

class DrugRepository {
  final Isar isar;

  DrugRepository(this.isar);

  // إضافة دواء جديد
  Future<void> addDrug(Drug drug) async {
    await isar.writeTxn(() async {
      await isar.drugs.put(drug);
    });
  }

  // تعديل دواء موجود
  Future<void> updateDrug(Drug drug) async {
    await isar.writeTxn(() async {
      await isar.drugs.put(drug);
    });
  }

  // حذف دواء
  Future<void> deleteDrug(int id) async {
    await isar.writeTxn(() async {
      await isar.drugs.delete(id);
    });
  }

  // جلب جميع الأدوية
  Future<List<Drug>> getAllDrugs() async {
    return await isar.drugs.where().findAll();
  }

  // البحث بالاسم (جزء من الاسم)
  Future<List<Drug>> searchByName(String query) async {
    return await isar.drugs
        .where()
        .filter()
        .nameContains(query)
        .findAll();
  }

  // البحث عن الأدوية التي قلّت عن حد إعادة الطلب
  Future<List<Drug>> getLowStockDrugs() async {
    final all = await getAllDrugs();
    return all.where((d) => d.quantity <= d.reorderLevel).toList();
  }

  // جلب دواء حسب الباركود
  Future<Drug?> getByBarcode(String barcode) async {
    return await isar.drugs
        .where()
        .filter()
        .barcodeEqualTo(barcode)
        .findFirst();
  }
}