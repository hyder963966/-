import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/drug_repository.dart';
import '../data/models/drug.dart';
import 'add_drug_screen.dart';

final allDrugsProvider = FutureProvider<List<Drug>>((ref) async {
  final repo = ref.watch(drugRepoProvider);
  return repo.getAllDrugs();
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drugsAsync = ref.watch(allDrugsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مخزون الأدوية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDrugScreen()),
              );
              // تحديث القائمة بعد العودة
              ref.invalidate(allDrugsProvider);
            },
          )
        ],
      ),
      body: drugsAsync.when(
        data: (drugs) {
          if (drugs.isEmpty) {
            return const Center(child: Text('لا توجد أدوية بعد'));
          }
          return ListView.builder(
            itemCount: drugs.length,
            itemBuilder: (context, index) {
              final drug = drugs[index];
              return ListTile(
                leading: const Icon(Icons.medication, color: Colors.teal),
                title: Text(drug.name),
                subtitle: Text('الكمية: ${drug.quantity} | السعر: ${drug.price} ل.س'),
                trailing: Text(drug.dosageForm),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}