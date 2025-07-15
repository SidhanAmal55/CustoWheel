import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); // 👈 Updated line
    
    
    
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    String extractedText = recognizedText.text;

    // 🔍 UAE plate pattern: 1–2 letters + 3–6 digits (optionally with space)
    // ✅ Match just digits (3 to 6): UAE simple plate (e.g., 42985)
    final uaeDigitsOnly = RegExp(r'\b\d{3,6}\b');
    final digitsMatch = uaeDigitsOnly.firstMatch(extractedText);
    if (digitsMatch != null) return digitsMatch.group(0)!;
    
    final uaeRegex = RegExp(r'\b\d{1,2}\s\d{3,6}\b');
    final uaeMatch = uaeRegex.firstMatch(extractedText.toUpperCase());
    if (uaeMatch != null) return uaeMatch.group(0)!;


    final regex = RegExp(r'\b([A-Z]{1,2}\s?\d{3,6})\b');
    final match = regex.firstMatch(extractedText.toUpperCase());

    return match?.group(0) ?? extractedText;
  }
}
