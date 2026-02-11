# 🎯 Flutter Translator App - Yapılandırma Rehberi

## 📍 IP Adresi Yapılandırması

### Otomatik IP Bulma

**Windows:**
\`\`\`powershell
ipconfig | findstr /i "IPv4"
\`\`\`

**Mac/Linux:**
\`\`\`bash
ifconfig | grep "inet " | grep -v 127.0.0.1
\`\`\`

### IP Adresini Uygulamaya Girme

#### Yöntem 1: Kod İçinde (Önerilen - Geliştirme)
**lib/main.dart** - Satır 18:
\`\`\`dart
TranslatorProvider(
  host: '192.168.1.100', // Burayı değiştirin
)
\`\`\`

#### Yöntem 2: Uygulama İçinde (Önerilen - Test)
1. Uygulamayı açın
2. Sağ üst köşedeki **⚙️ Ayarlar**'a tıklayın
3. **Sunucu IP Adresi** alanına IP'nizi yazın
4. **Kaydet ve Yeniden Bağlan** butonuna basın

## 🔌 Port Yapılandırması

Varsayılan portlar:

| Servis | Port | Açıklama |
|--------|------|----------|
| WebSocket | 8080 | Kullanıcı bağlantıları |
| Dil Algılama | 5000 | Flask Whisper API |
| Text-to-Speech | 5002 | Flask gTTS API |

### Port Değiştirme (Gerekirse)

**lib/services/websocket_service.dart:**
\`\`\`dart
Uri.parse('ws://\$host:8080'), // Port burada
\`\`\`

**lib/services/api_service.dart:**
\`\`\`dart
'http://\$host:5000/detect_language', // Dil algılama portu
'http://\$host:5002/text_to_speech',   // TTS portu
\`\`\`

## 🔐 Güvenlik Yapılandırması

### Geliştirme Ortamı
- HTTP bağlantıları varsayılan olarak açık
- Firewall kurallarına izin verilmeli
- Aynı WiFi ağında olunmalı

### Üretim Ortamı
\`\`\`dart
// lib/main.dart içinde
TranslatorProvider(
  host: 'your-production-domain.com',
  useHttps: true, // HTTPS kullan
)
\`\`\`

## 📱 Platform Spesifik Ayarlar

### Android
**android/app/build.gradle** - minSdkVersion:
\`\`\`gradle
minSdkVersion 21 // En az Android 5.0
\`\`\`

### iOS
**ios/Podfile** - platform:
\`\`\`ruby
platform :ios, '12.0' # En az iOS 12
\`\`\`

## 🎤 Mikrofon İzinleri

### İzinlerin Kontrolü
**Ayarlar ekranından** → **Servis Durumu** → Yeşil ✅ işareti görmeli

### Manuel İzin Verme

**Android:**
\`\`\`
Ayarlar → Uygulamalar → Real-Time Translator → İzinler → Mikrofon ✅
\`\`\`

**iOS:**
\`\`\`
Settings → Privacy → Microphone → Real-Time Translator ✅
\`\`\`

## 🌐 Dil Yapılandırması

### Desteklenen Diller
Uygulama içinde 13 dil mevcuttur:
- tr-TR (Türkçe)
- en-US (İngilizce)
- fr-FR (Fransızca)
- de-DE (Almanca)
- es-ES (İspanyolca)
- it-IT (İtalyanca)
- pt-PT (Portekizce)
- ru-RU (Rusça)
- ja-JP (Japonca)
- zh-CN (Çince)
- ar-SA (Arapça)
- ko-KR (Korece)
- hi-IN (Hintçe)

### Yeni Dil Ekleme
**lib/screens/home_screen.dart** - DropdownMenuItem listesine ekleyin:
\`\`\`dart
DropdownMenuItem(value: 'nl-NL', child: Text('🇳🇱 Nederlands')),
\`\`\`

## 🎛️ Performans Ayarları

### Ses Kaydı Kalitesi
**lib/services/audio_service.dart:**
\`\`\`dart
const RecordConfig(
  encoder: AudioEncoder.aacLc,
  sampleRate: 44100,  // Kaliteyi düşürmek için: 16000
  bitRate: 128000,    // Kaliteyi düşürmek için: 64000
)
\`\`\`

### WebSocket Timeout
**lib/services/websocket_service.dart:**
\`\`\`dart
// Connection timeout eklenebilir
final channel = WebSocketChannel.connect(
  Uri.parse('ws://\$host:8080'),
).timeout(Duration(seconds: 10));
\`\`\`

## 🧪 Debug Modu

### Console Log Kontrolü
Tüm servislerde `print()` logları vardır:
- 🔌 WebSocket bağlantıları
- 📡 API istekleri
- 🎤 Ses kayıtları
- 🌐 Çeviri sonuçları

### Debug Log Kapatma
Üretim build'inde otomatik kapatılır:
\`\`\`bash
flutter build apk --release
\`\`\`

## 🔧 Sorun Giderme Checklist

- [ ] IP adresi doğru girildi
- [ ] Backend servisleri çalışıyor
- [ ] Firewall kapalı veya izinler verildi
- [ ] Cihaz aynı WiFi ağında
- [ ] Mikrofon izni verildi
- [ ] İnternet bağlantısı var
- [ ] Flutter paketleri güncel (`flutter pub get`)

## 💡 İpuçları

1. **İlk test için**: Start Recording kullanın (backend gerektirmez)
2. **İki cihaz testi**: Aynı WiFi'ye bağlayın
3. **Uzaktan test**: Port forwarding veya ngrok kullanın
4. **Performans**: Gereksiz logları kapatın
5. **Pil tasarrufu**: Start Speaking'i sadece ihtiyaç halinde kullanın

## 📞 Destek

Sorun mu yaşıyorsunuz?
1. `flutter doctor` çalıştırın
2. Console loglarını kontrol edin
3. Backend servis durumunu test edin
4. README.md'deki Troubleshooting bölümüne bakın

---

**Başarılar! 🎉**
