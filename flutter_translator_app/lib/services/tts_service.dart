import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;
  List<String> _speechQueue = [];

  bool get isSpeaking => _isSpeaking;

  TtsService() {
    _initializeTts();
  }

  void _initializeTts() async {
    // Platform spesifik ayarlar
    if (Platform.isAndroid) {
      await _flutterTts.setEngine('com.google.android.tts');
    }

    await _flutterTts.setLanguage('tr-TR');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);

    // TTS durumunu dinle
    _flutterTts.setCompletionHandler(() {
      print('✅ TTS tamamlandı');
      _isSpeaking = false;
      _playNextInQueue();
    });

    _flutterTts.setErrorHandler((msg) {
      print('❌ TTS hatası: $msg');
      _isSpeaking = false;
      _playNextInQueue();
    });

    print('✅ TTS başlatıldı');
  }

  // Metni seslendir (Flutter TTS ile)
  Future<void> speak(String text, {String language = 'tr-TR'}) async {
    try {
      await _flutterTts.setLanguage(language);
      _isSpeaking = true;
      print('🔊 Seslendiriliyor: $text (Dil: $language)');
      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ TTS hatası: $e');
      _isSpeaking = false;
    }
  }

  // Kuyruğa ekle
  void addToQueue(String text) {
    _speechQueue.add(text);
    if (!_isSpeaking) {
      _playNextInQueue();
    }
  }

  void _playNextInQueue() {
    if (_speechQueue.isEmpty) return;
    
    final text = _speechQueue.removeAt(0);
    speak(text);
  }

  // Ses dosyasını çal (MP3 için - API'den gelen sesler)
  Future<void> playAudioFile(String filePath) async {
    try {
      print('🔊 Ses dosyası çalınıyor: $filePath');
      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      print('❌ Ses çalma hatası: $e');
    }
  }

  // Sesi durdur
  Future<void> stop() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    _isSpeaking = false;
    _speechQueue.clear();
    print('🛑 Seslendirme durduruldu');
  }

  // Duraklatma/Devam
  Future<void> pause() async {
    await _flutterTts.pause();
    await _audioPlayer.pause();
    print('⏸️ Seslendirme duraklatıldı');
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    print('▶️ Seslendirme devam ediyor');
  }

  // Desteklenen dilleri al
  Future<List<dynamic>> getLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages;
    } catch (e) {
      print('❌ Dil listesi alma hatası: $e');
      return [];
    }
  }

  // Desteklenen sesleri al
  Future<List<dynamic>> getVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices;
    } catch (e) {
      print('❌ Ses listesi alma hatası: $e');
      return [];
    }
  }

  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _speechQueue.clear();
  }
}
