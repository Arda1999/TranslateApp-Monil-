import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/websocket_service.dart';
import '../services/translation_service.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

class TranslatorProvider extends ChangeNotifier {
  // Services
  late WebSocketService _webSocketService;
  late TranslationService _translationService;
  late ApiService _apiService;
  late AudioService _audioService;
  late SpeechService _speechService;
  late TtsService _ttsService;

  // State
  String _host = '192.168.1.100'; // Varsayılan host
  String? _userId;
  String _userName = 'Misafir'; // Kullanıcı ID (özelleştirilebilir)
  String? _connectedUserId;
  String _selectedLanguage = 'tr-TR';
  String _recognizedText = '';
  String _translatedText = '';
  bool _isConnected = false;
  bool _isRecording = false;
  bool _isListening = false;
  bool _textToSpeechEnabled = true;
  bool _autoDetectLanguage = true; // Otomatik dil tespiti
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _conversationHistory = [];
  
  // Global connection request callback (her sayfadan erişilebilir)
  Function(String fromUserId, String fromUserName)? onConnectionRequestReceived;

  // Getters
  String get host => _host;
  String? get userId => _userId;
  String get userName => _userName;
  String? get connectedUserId => _connectedUserId;
  String get connectedUserName {
    if (_connectedUserId == null) return '';
    final user = _userList.firstWhere(
      (u) => u['id'] == _connectedUserId,
      orElse: () => {},
    );
    return user['userName'] ?? user['username'] ?? 'Misafir';
  }
  String get selectedLanguage => _selectedLanguage;
  String get recognizedText => _recognizedText;
  String get translatedText => _translatedText;
  bool get isConnected => _isConnected;
  bool get isRecording => _isRecording;
  bool get isListening => _isListening;
  bool get textToSpeechEnabled => _textToSpeechEnabled;
  bool get autoDetectLanguage => _autoDetectLanguage;
  List<Map<String, dynamic>> get userList => _userList;
  List<Map<String, dynamic>> get conversationHistory => _conversationHistory;
  Stream<Map<String, dynamic>>? get messageStream => _webSocketService.messageStream;

  TranslatorProvider({String? host}) {
    if (host != null) _host = host;
    _loadUserName();
    _initializeServices();
  }

  // Kullanıcı adını yükle
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? 'Misafir';
  }

  void _initializeServices() {
    _webSocketService = WebSocketService(host: _host);
    _translationService = TranslationService();
    _apiService = ApiService(host: _host);
    _audioService = AudioService();
    _speechService = SpeechService();
    _ttsService = TtsService();

    _setupListeners();
  }

  void _setupListeners() {
    // WebSocket mesajlarını dinle
    _webSocketService.messageStream.listen((message) {
      _handleWebSocketMessage(message);
    });

    // Kullanıcı listesi güncellemelerini dinle
    _webSocketService.userListStream.listen((users) {
      _userList = users;
      notifyListeners();
    });

    // Bağlantı durumunu dinle
    _webSocketService.connectionStatusStream.listen((connected) {
      _isConnected = connected;
      if (connected) {
        _userId = _webSocketService.userId;
      }
      notifyListeners();
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'user_id':
        _userId = message['userId'];
        print('🆔 Provider: Kullanıcı ID güncellendi: $_userId');
        // Kullanıcı adını sunucuya gönder
        _webSocketService.sendDeviceInfo(userName: _userName);
        notifyListeners();
        break;

      case 'connect_confirmed':
        _connectedUserId = message['targetUserId'];
        notifyListeners();
        break;

      case 'connect_rejected':
        _connectedUserId = null;
        notifyListeners();
        break;
      
      case 'connect_request':
        // Global callback ile tüm sayfalarda bildirim göster
        if (onConnectionRequestReceived != null) {
          final fromUserName = message['fromUserName'] ?? 'Misafir';
          onConnectionRequestReceived!(message['fromUserId'], fromUserName);
        }
        break;

      case 'audio':
        _handleIncomingAudio(message['audioData']);
        break;

      default:
        // Diğer mesajlar için callback kullanılabilir
        break;
    }
  }

  Future<void> _handleIncomingAudio(String audioBase64) async {
    try {
      // Base64'ten ses dosyası oluştur
      final bytes = base64Decode(audioBase64);
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioFile = File('${tempDir.path}/incoming_$timestamp.mp3');
      await audioFile.writeAsBytes(bytes);

      // Sesi çal
      await _ttsService.playAudioFile(audioFile.path);
      print('🔊 Gelen ses çalındı');
    } catch (e) {
      print('❌ Gelen ses işleme hatası: $e');
    }
  }

  // Host ayarla ve kaydet
  Future<void> setHost(String host) async {
    _host = host;
    
    // IP adresini kalıcı olarak kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_host', host);
    print('✅ IP adresi kaydedildi: $host');
    
    _initializeServices();
    notifyListeners();
  }

  // WebSocket bağlantısı kur
  Future<void> connectWebSocket() async {
    await _webSocketService.connect();
  }

  // WebSocket bağlantısını kes
  void disconnectWebSocket() {
    _webSocketService.disconnect();
    _connectedUserId = null;
    notifyListeners();
  }

  // Kullanıcıya bağlantı isteği gönder
  void sendConnectionRequest(String targetUserId) {
    _webSocketService.sendConnectionRequest(targetUserId);
  }

  // Bağlantı isteğine yanıt ver
  void respondToConnectionRequest(String fromUserId, bool accepted) {
    _webSocketService.sendConnectionResponse(fromUserId, accepted);
    if (accepted) {
      _connectedUserId = fromUserId;
      notifyListeners();
    }
  }

  // Mevcut kullanıcıdan bağlantıyı kes
  void disconnectFromUser() {
    if (_connectedUserId != null) {
      // Karşı tarafa bildirim gönder
      _webSocketService.send({
        'type': 'disconnect',
        'targetUserId': _connectedUserId,
      });
      
      _connectedUserId = null;
      notifyListeners();
      print('🔌 Bağlantı kesildi');
    }
  }

  // Dil seç
  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Kullanıcı ID'sini değiştir
  Future<void> setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'Misafir' : name.trim();
    notifyListeners();
    
    // Kaydedilsin (kalıcı)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    
    // WebSocket'e bildir (eğer bağlıysa)
    if (_userId != null) {
      _webSocketService.send({
        'type': 'update_username',
        'userId': _userId,
        'username': _userName,
      });
    }
  }

  // Otomatik dil tespitini aç/kapat
  void toggleAutoDetectLanguage(bool enabled) {
    _autoDetectLanguage = enabled;
    notifyListeners();
  }

  // Text-to-Speech'i aç/kapat
  void toggleTextToSpeech(bool enabled) {
    _textToSpeechEnabled = enabled;
    notifyListeners();
  }

  // START RECORDING - Yerel test modu (5 saniye kaydet + dil algıla + konuşma tanıma)
  Future<void> startRecording() async {
    try {
      print('🎙️ Start Recording: Yerel mod başlatılıyor');
      _textToSpeechEnabled = true; // Çeviri yapılsın ve seslendirilsin
      
      // Eğer otomatik dil tespiti KAPALI ise, direkt konuşma tanımayı başlat
      if (!_autoDetectLanguage) {
        print('⚡ Otomatik dil tespiti kapalı, direkt konuşma tanıma başlatılıyor...');
        await _startSpeechRecognition(false);
        return;
      }
      
      // Otomatik dil tespiti AÇIK: 5 saniye ses kaydı yap
      final success = await _audioService.startRecording(
        duration: const Duration(seconds: 4),
      );

      if (!success) {
        print('❌ Ses kaydı başlatılamadı');
        return;
      }

      _isRecording = true;
      notifyListeners();

      // 5 saniye sonra işlemlere devam et
      await Future.delayed(const Duration(seconds: 5));
      
      final recordingPath = await _audioService.stopRecording();
      _isRecording = false;
      notifyListeners();

      if (recordingPath == null) {
        print('❌ Kayıt alınamadı');
        return;
      }

      // Dil algılama
      final languageResult = await _apiService.detectLanguage(recordingPath);
      if (languageResult != null) {
        final detectedLang = languageResult['predicted_language'];
        print('🌐 Algılanan dil: $detectedLang');
        
        // Dil seçimini güncelle
        if (detectedLang == 'tr' || detectedLang == 'nn' || detectedLang == 'jw') {
          setLanguage('tr-TR');
        } else if (detectedLang == 'en') {
          setLanguage('en-US');
        }
      }

      // Konuşma tanımayı başlat
      await _startSpeechRecognition(false); // WebSocket'e gönderme
      
    } catch (e) {
      print('❌ Start Recording hatası: $e');
      _isRecording = false;
      _textToSpeechEnabled = true;
      notifyListeners();
    }
  }

  // START SPEAKING - WebSocket ile ses gönderme modu
  Future<void> startSpeaking() async {
    try {
      if (_connectedUserId == null) {
        print('⚠️ Bağlantı kurmadan konuşamazsınız');
        return;
      }

      print('🗣️ Start Speaking: WebSocket modu başlatılıyor');
      _textToSpeechEnabled = true; // Seslendirmeyi aç
      
      // 5 saniye ses kaydı yap (dil algılama için)
      final success = await _audioService.startRecording(
        duration: const Duration(seconds: 5),
      );

      if (!success) {
        print('❌ Ses kaydı başlatılamadı');
        return;
      }

      _isRecording = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 5));
      
      final recordingPath = await _audioService.stopRecording();
      _isRecording = false;
      notifyListeners();

      if (recordingPath != null) {
        // Dil algılama (opsiyonel)
        await _apiService.detectLanguage(recordingPath);
      }

      // Konuşma tanımayı başlat
      await _startSpeechRecognition(true); // WebSocket'e gönder
      
    } catch (e) {
      print('❌ Start Speaking hatası: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  // Konuşma tanımayı başlat
  String _cumulativeTranscript = ''; // Web'deki gibi transcript biriktir
  
  Future<void> _startSpeechRecognition(bool sendToWebSocket) async {
    try {
      final initialized = await _speechService.initialize();
      if (!initialized) {
        print('❌ Speech servis başlatılamadı');
        return;
      }

      _isListening = true;
      _cumulativeTranscript = ''; // Başlangıçta temizle
      notifyListeners();

      await _speechService.startListening(
        languageId: _selectedLanguage,
        onResult: (text) {
          // Geçici sonuç - sadece şu anki kelimeyi göster (Web'deki gibi)
          _recognizedText = text;
          notifyListeners();
        },
        onFinalResult: (text) async {
          // Web'deki gibi: Cümle BİTTİKTEN SONRA transcript'e ekle
          if (_cumulativeTranscript.isNotEmpty) {
            _cumulativeTranscript += ' ' + text;
          } else {
            _cumulativeTranscript = text;
          }
          
          // UI'da birikmiş transcript'i göster (cümle bittikten sonra)
          _recognizedText = _cumulativeTranscript;
          notifyListeners();
          
          print('📝 Biriken transcript: $_cumulativeTranscript');
          
          // Tüm birikmiş transcript'i çevir
          await _translateAndSpeak(_cumulativeTranscript, sendToWebSocket);
        },
      );
    } catch (e) {
      print('❌ Konuşma tanıma başlatma hatası: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  // Çeviri yap ve seslendir
  Future<void> _translateAndSpeak(String text, bool sendToWebSocket) async {
    try {
      // Kaynak dili belirle
      final sourceLang = _translationService.getLanguageCode(_selectedLanguage);
      
      // Hedef dili belirle
      // 🇹🇷 Türkçe → 🇬🇧 İngilizce (seslendirme İngilizce)
      // 🌍 Diğer tüm diller → 🇹🇷 Türkçe (seslendirme Türkçe)
      final targetLang = sourceLang == 'tr' ? 'en' : 'tr';
      
      // Çevir
      final translated = await _translationService.translate(
        text: text,
        from: sourceLang,
        to: targetLang,
      );

      _translatedText = translated;
      
      // Geçmişe ekle
      _conversationHistory.add({
        'original': text,
        'translated': translated,
        'language': _selectedLanguage,
        'timestamp': DateTime.now(),
      });
      
      notifyListeners();

      // Text-to-Speech (sadece etkinse)
      if (_textToSpeechEnabled) {
        // API üzerinden TTS (daha kaliteli)
        final audioPath = await _apiService.textToSpeech(
          text: translated,
          language: targetLang,
        );

        if (audioPath != null) {
          // WebSocket'e gönder (eğer aktifse)
          if (sendToWebSocket && _connectedUserId != null) {
            final base64Audio = await _audioService.audioToBase64(audioPath);
            if (base64Audio != null) {
              _webSocketService.sendAudio(base64Audio, _connectedUserId!);
              print('📡 Ses WebSocket üzerinden gönderildi');
            }
          }
          
          // Yerel olarak ÇALMAYIN (sadece karşı tarafa gitsin)
          // await _ttsService.playAudioFile(audioPath);
        }
      }
      
      // Her çeviri ve TTS işleminden sonra transcript ve translation'ı temizle
      // (WebSocket gönderimi olsun ya da olmasın)
      _cumulativeTranscript = '';
      _recognizedText = '';
      _translatedText = '';
      notifyListeners();
      print('🔄 Transcript ve translation temizlendi - yeni konuşma için hazır');
      
      // ARTIK YENİDEN BAŞLATMAYA GEREK YOK!
      // Speech service kendi kendine otomatik yeniden başlatıyor (Web gibi)
      // onStatus: "done" → auto-restart
      // onError: "error_no_match" → auto-restart
      
    } catch (e) {
      print('❌ Çeviri ve seslendirme hatası: $e');
    }
  }

  // Kaydı durdur
  Future<void> stopRecording() async {
    await _speechService.stopListening();
    _isListening = false;
    _textToSpeechEnabled = true;
    _cumulativeTranscript = ''; // Transcript'i temizle - yeni başlatıldığında temiz başlasın
    notifyListeners();
  }

  // Metni temizle
  void clearText() {
    _recognizedText = '';
    _translatedText = '';
    notifyListeners();
  }

  // Geçmişi temizle
  void clearHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }

  // Servislerin durumunu kontrol et
  Future<Map<String, bool>> checkServices() async {
    return await _apiService.checkAllServices();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    _audioService.dispose();
    _speechService.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}
