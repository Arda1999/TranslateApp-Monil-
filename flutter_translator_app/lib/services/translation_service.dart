import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      print('🌐 Çeviri yapılıyor: $from → $to');
      final translation = await _translator.translate(
        text,
        from: from,
        to: to,
      );
      print('✅ Çeviri tamamlandı');
      return translation.text;
    } catch (e) {
      print('❌ Çeviri hatası: $e');
      return 'Çeviri hatası';
    }
  }

  Future<String> translateToEnglish(String text, String fromLanguage) async {
    return await translate(text: text, from: fromLanguage, to: 'en');
  }

  Future<String> translateToTurkish(String text, String fromLanguage) async {
    return await translate(text: text, from: fromLanguage, to: 'tr');
  }

  // Dil kodunu Google Translate formatına çevir
  String getLanguageCode(String fullCode) {
    // tr-TR → tr, en-US → en
    return fullCode.split('-').first;
  }
}
