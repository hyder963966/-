import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../data/syrian_drugs.dart';
import 'dart:io';

// هذه الشاشة ترجع لنا اسم الدواء (nullable) و الباركود (nullable)
class DrugScannerScreen extends StatefulWidget {
  const DrugScannerScreen({super.key});
  @override
  State<DrugScannerScreen> createState() => _DrugScannerScreenState();
}

class _DrugScannerScreenState extends State<DrugScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _suggestedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح الدواء')),
      body: Stack(
        children: [
          // ماسح الباركود المباشر
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              if (_isProcessing) return;
              final barcode = capture.barcodes.firstOrNull;
              if (barcode != null && barcode.rawValue != null) {
                // وجدنا باركود، نرجع به
                Navigator.pop(context, {'barcode': barcode.rawValue});
              }
            },
          ),
          // زر التقاط الصورة لتحليل OCR
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('لم يظهر باركود؟ صور العلبة'),
              onPressed: _isProcessing ? null : _captureAndOCR,
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
          if (_suggestedName != null)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('تم التعرف: $_suggestedName'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {'name': _suggestedName});
                    },
                    child: const Text('استخدم هذا'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _captureAndOCR() async {
    setState(() => _isProcessing = true);
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      // استخراج النصوص من الصورة
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      String fullText = recognizedText.text;
      // أبسط استخلاص: نأخذ السطر الأطول كمرشح لاسم الدواء
      final lines = fullText.split('\n');
      String longestLine = '';
      for (final line in lines) {
        if (line.trim().length > longestLine.length) {
          longestLine = line.trim();
        }
      }
      // نحاول تطابق ضبابي مع القائمة السورية
      final matched = fuzzyMatchDrugName(longestLine);
      if (matched != null) {
        setState(() => _suggestedName = matched);
      } else {
        // لا يوجد تطابق كافي، نعرض السطر الأطول للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('النص المستخرج: "$longestLine"')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}