import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiService {
  final String host;
  final Dio _dio = Dio();

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
      
      final response = await http.post(
        Uri.parse('http://$host:5002/text_to_speech'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        // MP3 dosyasını geçici bir yere kaydet
        final bytes = response.bodyBytes;
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await tempFile.writeAsBytes(bytes);
        
        print('✅ Ses dosyası oluşturuldu: ${tempFile.path}');
        return tempFile.path;
      } else {
        print('❌ Text-to-Speech hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Text-to-Speech hatası: $e');
      return null;
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
      'textToSpeech': await checkHealth(5002),
    };
  }
}
