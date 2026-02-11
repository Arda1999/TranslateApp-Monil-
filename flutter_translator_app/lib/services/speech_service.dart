import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _shouldKeepListening = false; // Web gibi sürekli dinleme
  String? _currentLanguageId;
  Function(String)? _currentOnResult;
  Function(String)? _currentOnFinalResult;

  final ValueNotifier<String> recognizedTextNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier<bool>(false);

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Servis başlatma ve izin kontrolü
  Future<bool> initialize() async {
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          print('❌ Speech hatası: ${error.errorMsg}');
          
          // error_no_match: Ses gelmeden başlatıldı, normal bir durum - yeniden başlat
          if (error.errorMsg == 'error_no_match' && _shouldKeepListening) {
            print('🔄 error_no_match - yeniden başlatılıyor (Web gibi sürekli dinleme)...');
            _isListening = false;
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (_shouldKeepListening && _currentLanguageId != null) {
                startListening(
                  languageId: _currentLanguageId!,
                  onResult: _currentOnResult!,
                  onFinalResult: _currentOnFinalResult,
                );
              }
            });
          } else {
            _isListening = false;
            isListeningNotifier.value = false;
          }
        },
        onStatus: (status) {
          print('🎤 Speech durumu: $status');
          // Web'deki gibi: done durumunda yeniden başlat
          if (status == 'done' && _shouldKeepListening && _currentLanguageId != null) {
            print('🔄 Status done - yeniden başlatılıyor (Web gibi)...');
            _isListening = false;
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (_shouldKeepListening && _currentLanguageId != null) {
                startListening(
                  languageId: _currentLanguageId!,
                  onResult: _currentOnResult!,
                  onFinalResult: _currentOnFinalResult,
                );
              }
            });
          }
        },
      );

      if (_isInitialized) {
        print('✅ Speech-to-Text başlatıldı');
      } else {
        print('❌ Speech-to-Text başlatılamadı');
      }

      return _isInitialized;
    } catch (e) {
      print('❌ Speech-to-Text başlatma hatası: $e');
      _isInitialized = false;
      return false;
    }
  }

  // Konuşma tanımayı başlat
  Future<void> startListening({
    required String languageId,
    required Function(String) onResult,
    Function(String)? onFinalResult,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Speech-to-Text başlatılmamış');
      await initialize();
    }

    if (_isListening) {
      print('⚠️ Zaten dinleniyor');
      return;
    }

    // Callback'leri ve dili kaydet (auto-restart için)
    _currentLanguageId = languageId;
    _currentOnResult = onResult;
    _currentOnFinalResult = onFinalResult;
    _shouldKeepListening = true; // Web gibi sürekli dinleme aktif

    try {
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          final recognizedWords = result.recognizedWords;
          recognizedTextNotifier.value = recognizedWords;
          onResult(recognizedWords);

          // Final (kesinleşmiş) sonuç
          if (result.finalResult && onFinalResult != null) {
            print('✅ Final sonuç: $recognizedWords');
            onFinalResult(recognizedWords);
          }
        },
        localeId: languageId,
        listenMode: ListenMode.dictation, // Web'deki continuous: true gibi
        cancelOnError: false,
        partialResults: true, // Anlık sonuçları al
        listenFor: const Duration(hours: 8), // Web gibi çok uzun - manuel stop gerekir
        pauseFor: const Duration(minutes: 30), // Web gibi - sessizlikten durmasın
      );

      _isListening = true;
      isListeningNotifier.value = true;
      print('🎤 Konuşma tanıma başlatıldı (Dil: $languageId)');
    } catch (e) {
      print('❌ Konuşma tanıma başlatma hatası: $e');
      _isListening = false;
      isListeningNotifier.value = false;
    }
  }

  // Konuşma tanımayı durdur
  Future<void> stopListening() async {
    _shouldKeepListening = false; // Auto-restart'ı devre dışı bırak
    
    if (!_isListening) {
      print('⚠️ Zaten dinlemiyor');
      return;
    }

    try {
      await _speechToText.stop();
      _isListening = false;
      isListeningNotifier.value = false;
      print('🛑 Konuşma tanıma durduruldu');
    } catch (e) {
      print('❌ Konuşma tanıma durdurma hatası: $e');
    }
  }

  // Dinlemeyi iptal et
  Future<void> cancel() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      isListeningNotifier.value = false;
      recognizedTextNotifier.value = '';
      print('🚫 Konuşma tanıma iptal edildi');
    } catch (e) {
      print('❌ İptal hatası: $e');
    }
  }

  // Desteklenen dilleri al
  Future<List<LocaleName>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final locales = await _speechToText.locales();
      print('🌐 Desteklenen diller: ${locales.length}');
      return locales;
    } catch (e) {
      print('❌ Dil listesi alma hatası: $e');
      return [];
    }
  }

  void dispose() {
    _speechToText.cancel();
    recognizedTextNotifier.dispose();
    isListeningNotifier.dispose();
  }
}
