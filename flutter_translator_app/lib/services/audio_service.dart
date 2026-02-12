import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  // Mikrofon izni kontrolü
  Future<bool> checkPermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      print(hasPermission ? '✅ Mikrofon izni var' : '❌ Mikrofon izni yok');
      return hasPermission;
    } catch (e) {
      print('❌ İzin kontrolü hatası: $e');
      return false;
    }
  }

  // Ses kaydını başlat
  Future<bool> startRecording({Duration? duration}) async {
    try {
      if (_isRecording) {
        print('⚠️ Zaten kayıt yapılıyor');
        return false;
      }

      final hasPermission = await checkPermission();
      if (!hasPermission) {
        print('❌ Mikrofon izni verilmedi');
        return false;
      }

      // Geçici dosya yolu oluştur
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/recording_$timestamp.m4a';

      // Kaydı başlat
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      print('🎙️ Ses kaydı başlatıldı: $_currentRecordingPath');

      // duration parametresi çağıran tarafta kontrol ediliyor.
      // Burada otomatik stop yapılırsa, çağıran tekrar stop çağırdığında
      // "⚠️ Kayıt yapılmıyor" ve null path problemi oluşuyor.

      return true;
    } catch (e) {
      print('❌ Kayıt başlatma hatası: $e');
      _isRecording = false;
      return false;
    }
  }

  // Ses kaydını durdur
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        print('⚠️ Kayıt yapılmıyor');
        return null;
      }

      final path = await _recorder.stop();
      _isRecording = false;

      if (path != null) {
        print('✅ Ses kaydı durduruldu: $path');
        return path;
      } else {
        print('⚠️ Ses kaydı yolu alınamadı');
        return null;
      }
    } catch (e) {
      print('❌ Kayıt durdurma hatası: $e');
      _isRecording = false;
      return null;
    }
  }

  // Kaydı iptal et
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        
        // Dosyayı sil
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
            print('🗑️ Kayıt dosyası silindi');
          }
        }
      }
    } catch (e) {
      print('❌ Kayıt iptal hatası: $e');
    }
  }

  // Ses dosyasını base64'e çevir
  Future<String?> audioToBase64(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        print('❌ Ses dosyası bulunamadı: $audioPath');
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      print('✅ Ses dosyası base64\'e çevrildi (${bytes.length} bytes)');
      return base64String;
    } catch (e) {
      print('❌ Base64 dönüştürme hatası: $e');
      return null;
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}
