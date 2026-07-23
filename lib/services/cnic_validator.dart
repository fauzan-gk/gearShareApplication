import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CnicValidationResult {
  final bool isValid;
  final String? detectedNumber;
  final String? message;

  const CnicValidationResult({
    required this.isValid,
    this.detectedNumber,
    this.message,
  });
}

class CnicValidator {
  static final TextRecognizer? _recognizer = _initRecognizer();

  static TextRecognizer? _initRecognizer() {
    try {
      return TextRecognizer();
    } catch (_) {
      return null;
    }
  }

  static Future<CnicValidationResult> validateImage(Uint8List imageBytes) async {
    if (_recognizer == null) {
      return const CnicValidationResult(
        isValid: true,
        message: 'OCR not available on this platform',
      );
    }

    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cnic_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFile(tempFile);
      final RecognizedText recognizedText = await _recognizer!.processImage(inputImage);

      await tempFile.delete();

      final text = recognizedText.text;

      final cnicPattern = RegExp(r'\b\d{5}[-\s]?\d{7}[-\s]?\d{1}\b');
      final cnicMatch = cnicPattern.firstMatch(text);

      final hasCnicKeyword = text.contains(RegExp(r'CNIC|NADRA|IDENTITY|IDENTIFICATION|NATIONAL IDENTITY', caseSensitive: false));

      if (cnicMatch != null && hasCnicKeyword) {
        final cnicNumber = cnicMatch.group(0)!.replaceAll(RegExp(r'[-\s]'), '');
        return CnicValidationResult(
          isValid: true,
          detectedNumber: '${cnicNumber.substring(0, 5)}-${cnicNumber.substring(5, 12)}-${cnicNumber.substring(12)}',
          message: 'CNIC verified successfully',
        );
      }

      if (cnicMatch != null) {
        final cnicNumber = cnicMatch.group(0)!.replaceAll(RegExp(r'[-\s]'), '');
        return CnicValidationResult(
          isValid: true,
          detectedNumber: '${cnicNumber.substring(0, 5)}-${cnicNumber.substring(5, 12)}-${cnicNumber.substring(12)}',
          message: 'CNIC number detected',
        );
      }

      return const CnicValidationResult(
        isValid: false,
        message: 'No valid CNIC number found. Please upload a clear image of your CNIC.',
      );
    } on UnsupportedError {
      return const CnicValidationResult(
        isValid: true,
        message: 'OCR not supported on this platform',
      );
    } catch (e) {
      return CnicValidationResult(
        isValid: false,
        message: 'Failed to process image: $e',
      );
    }
  }

  static void dispose() {
    _recognizer?.close();
  }
}
