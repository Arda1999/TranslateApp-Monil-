import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiService {
  final String host;
  final Dio _dio = Dio();

  static const List<String> _ttsPaths = <String>[
    '/text_to_speech',
    '/text-to-speech',
  ];

  ApiService({required this.host});

  // Dil algılama servisi (Port 5000)
  Future<Map<String, dynamic>?> detectLanguage(String audioPath) async {
    try {
      print('🔍 Dil algılama başlatılıyor...');
      final file = File(audioPath);
      
      if (!await file.exists()) {
        print('❌ Ses dosyası bulunamadı: $audioPath');
        return null;
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'recording.mp3',
        ),
      });

      final response = await _dio.post(
        'http://$host:5000/detect_language',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Dil algılandı: ${response.data}');
        return response.data;
      } else {
        print('❌ Dil algılama hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Dil algılama hatası: $e');
      return null;
    }
  }

  // Text-to-Speech servisi (Port 5002)
  Future<String?> textToSpeech({
    required String text,
    String language = 'tr',
  }) async {
    try {
      print('🔊 Text-to-Speech başlatılıyor...');

      http.Response? lastResponse;
      for (final path in _ttsPaths) {
        final url = Uri.parse('http://$host:5002$path');
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'text': text,
                'language': language,
              }),
            )
            .timeout(const Duration(seconds: 10));

        lastResponse = response;
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final tempDir = Directory.systemTemp;
          final tempFile = File(
            '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
          );
          await tempFile.writeAsBytes(bytes);
          print('✅ Ses dosyası oluşturuldu: ${tempFile.path}');
          return tempFile.path;
        }

        // 404 ise farklı route adı denenebilir.
        if (response.statusCode == 404) {
          print('⚠️ TTS endpoint bulunamadı: $url (404)');
          continue;
        }

        final bodyPreview = response.body.length > 300
            ? '${response.body.substring(0, 300)}...'
            : response.body;
        print('❌ TTS hatası (${response.statusCode}) url=$url body=$bodyPreview');
        return null;
      }

      if (lastResponse != null) {
        print('❌ Text-to-Speech başarısız: son durum kodu ${lastResponse.statusCode}');
      }
      return null;
    } catch (e) {
      print('❌ Text-to-Speech hatası: $e');
      return null;
    }
  }

  // TTS servisini kontrol et: bazı backend'lerde /health olmayabilir.
  Future<bool> checkTextToSpeechService() async {
    try {
      // Önce TTS endpoint'ini OPTIONS ile probe et.
      // GET atarsak backend loglarında 405 görünüyor (method not allowed) ve kafa karıştırıyor.
      final client = http.Client();
      try {
        for (final path in _ttsPaths) {
          final url = Uri.parse('http://$host:5002$path');
          final request = http.Request('OPTIONS', url);
          final streamed = await client.send(request).timeout(const Duration(seconds: 3));
          final statusCode = streamed.statusCode;

          // 404 = route yok. 200/204 = OK. 405 = route var ama OPTIONS kapalı olabilir.
          if (statusCode != 404 && statusCode < 500) {
            return true;
          }
        }
      } finally {
        client.close();
      }

      // Endpoint bulunamadıysa son çare /health dene (bazı backend'ler eklemiş olabilir).
      final healthUrl = Uri.parse('http://$host:5002/health');
      final healthResponse = await http
          .get(healthUrl)
          .timeout(const Duration(seconds: 3));
      return healthResponse.statusCode == 200;
    } catch (e) {
      print('❌ TTS servis kontrol hatası (port 5002): $e');
      return false;
    }
  }

  // Health check
  Future<bool> checkHealth(int port) async {
    try {
      final response = await http.get(
        Uri.parse('http://$host:$port/health'),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check hatası (port $port): $e');
      return false;
    }
  }

  // Tüm servislerin durumunu kontrol et
  Future<Map<String, bool>> checkAllServices() async {
    return {
      'detectLanguage': await checkHealth(5000),
      'textToSpeech': await checkTextToSpeechService(),
    };
  }
}
