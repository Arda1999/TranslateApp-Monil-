# 📱 Real-Time Speech Translator - Flutter Mobile App

Gerçek zamanlı konuşma tanıma ve çeviri özelliklerine sahip Flutter mobil uygulaması. Web uygulamasının tüm işlevselliğini mobil platforma taşıyan tam teşekküllü bir çözüm.

## 🎯 Özellikler

### ✨ Temel Özellikler
- **🎤 Gerçek Zamanlı Konuşma Tanıma**: Anlık konuşma-metin dönüşümü
- **🌐 Otomatik Dil Algılama**: Whisper AI ile konuştuğunuz dili otomatik tespit
- **🔄 Anlık Çeviri**: Google Translate API ile hızlı çeviri
- **🔊 Text-to-Speech**: Çevrilen metinleri sesli okuma
- **📡 WebSocket Bağlantısı**: Kullanıcılar arası gerçek zamanlı iletişim
- **🎧 Ses İletimi**: Karşı tarafa ses gönderme ve alma

### 🎨 Kullanıcı Arayüzü
- **Modern Material Design 3**: Şık ve kullanıcı dostu arayüz
- **🌗 Dark Mode Desteği**: Otomatik tema değişimi
- **📊 Durum Göstergeleri**: WebSocket, kayıt ve dinleme durumu
- **📜 Konuşma Geçmişi**: Tüm çevirilerin kaydı

### 🔧 İki Çalışma Modu

#### 1️⃣ Start Recording (Yerel Test Modu)
- 5 saniye ses kaydı yaparak dil algılama
- Otomatik dil seçimi
- Sürekli konuşma tanıma
- Offline çeviri testi
- ⛔ Text-to-Speech devre dışı (ses karışmasını önler)

#### 2️⃣ Start Speaking (WebSocket Modu)
- Kullanıcılar arası bağlantı gerektirir
- Gerçek zamanlı ses iletimi
- Çift yönlü çeviri ve seslendirme
- ✅ Text-to-Speech aktif

## 🛠️ Kurulum

### Gereksinimler
- Flutter SDK (3.8.0+)
- Dart SDK
- Android Studio / Xcode
- Python 3.x (Backend servisleri için)
- Node.js (WebSocket sunucusu için)

### 1. Flutter Projesini Klonlayın
\`\`\`bash
cd flutter_translator_app
flutter pub get
\`\`\`

### 2. Backend Servislerini Başlatın

#### A) WebSocket Sunucusu (Port 8080)
\`\`\`bash
cd ../ConnectTsApp
npm install
npm start
\`\`\`

#### B) Flask Servisleri

**Dil Algılama (Port 5000):**
\`\`\`bash
cd ../FlaskDetectLanguage
python -m venv venv
venv\\Scripts\\activate  # Windows
# veya source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
python app.py
\`\`\`

**Text-to-Speech (Port 5002):**
\`\`\`bash
cd ../FlaskTextToSpeech
python -m venv venv
venv\\Scripts\\activate
pip install -r requirements.txt
python app.py
\`\`\`

### 3. IP Adresini Ayarlayın

**lib/main.dart** dosyasında host IP adresinizi güncelleyin:
\`\`\`dart
TranslatorProvider(
  host: '192.168.1.100', // Kendi IP adresiniz
)
\`\`\`

Veya uygulamadaki **Ayarlar** ekranından değiştirebilirsiniz.

### 4. Uygulamayı Çalıştırın

**Android:**
\`\`\`bash
flutter run
\`\`\`

**iOS:**
\`\`\`bash
flutter run
# veya Xcode ile açıp çalıştırın
\`\`\`

## 📱 Kullanım

### İlk Kurulum
1. Uygulamayı açın
2. **Ayarlar** → **Sunucu IP Adresi**'ni backend sunucunuzun IP'si ile değiştirin
3. **Kaydet ve Yeniden Bağlan** butonuna basın
4. Ana ekrana dönün ve WebSocket bağlantısının kurulduğunu kontrol edin

### Yerel Test (Start Recording)
1. Ana ekranda **Start Recording** butonuna basın
2. 5 saniye konuşun (dil algılanacak)
3. Konuşmaya devam edin
4. Transcript ve Translation bölümlerinde sonuçları görün

### Uzaktan Bağlantı (Start Speaking)
1. **Bağlan** butonuna basın
2. Kullanıcı listesinden birine tıklayarak bağlantı isteği gönderin
3. Karşı taraf kabul edince ana ekrana dönün
4. **Start Speaking** butonuna basın
5. Konuşun - ses karşı tarafa iletilecek ve çeviriler seslendirilecek

## 🎛️ Desteklenen Diller

- 🇹🇷 Türkçe
- 🇺🇸 English
- 🇫🇷 Français
- 🇩🇪 Deutsch
- 🇪🇸 Español
- 🇮🇹 Italiano
- 🇵🇹 Português
- 🇷🇺 Русский
- 🇯🇵 日本語
- 🇨🇳 中文
- 🇸🇦 العربية
- 🇰🇷 한국어
- 🇮🇳 हिन्दी

## 📡 API Endpoints

### WebSocket (Port 8080)
- Kullanıcı kayıt ve yönetimi
- Bağlantı istekleri
- Ses veri iletimi

### Flask Servisleri
- **POST /detect_language** (Port 5000) - Dil algılama
- **POST /text_to_speech** (Port 5002) - Metin→Ses dönüşümü
- **GET /health** - Servis durumu kontrolü

## 🔐 İzinler

### Android
- `INTERNET` - Ağ erişimi
- `RECORD_AUDIO` - Mikrofon erişimi
- `WRITE_EXTERNAL_STORAGE` - Dosya yazma
- `MODIFY_AUDIO_SETTINGS` - Ses ayarları

### iOS
- `NSMicrophoneUsageDescription` - Mikrofon izni
- `NSSpeechRecognitionUsageDescription` - Konuşma tanıma izni
- `NSAppTransportSecurity` - HTTP bağlantıları

## 🏗️ Proje Yapısı

\`\`\`
lib/
├── main.dart                          # Ana uygulama
├── providers/
│   └── translator_provider.dart       # State management
├── services/
│   ├── websocket_service.dart         # WebSocket bağlantısı
│   ├── translation_service.dart       # Çeviri servisi
│   ├── api_service.dart               # HTTP API istekleri
│   ├── audio_service.dart             # Ses kaydetme
│   ├── speech_service.dart            # Konuşma tanıma
│   └── tts_service.dart               # Text-to-Speech
└── screens/
    ├── home_screen.dart               # Ana ekran
    ├── connection_screen.dart         # Bağlantı yönetimi
    └── settings_screen.dart           # Ayarlar
\`\`\`

## 🐛 Troubleshooting

### WebSocket Bağlanamıyor
- Backend sunucusunun çalıştığından emin olun
- IP adresinin doğru olduğunu kontrol edin
- Firewall ayarlarını kontrol edin
- `ping 192.168.1.100` ile bağlantıyı test edin

### Mikrofon Çalışmıyor
- Uygulama izinlerini kontrol edin
- Cihaz ayarlarından mikrofon iznini verin
- Android: Settings → Apps → Translator → Permissions
- iOS: Settings → Privacy → Microphone

### Konuşma Tanımıyor
- İnternet bağlantısını kontrol edin
- Desteklenen diller listesinden seçim yapın
- Mikrofonu test edin
- Arka plan gürültüsünü azaltın

### Flask Servisleri Çalışmıyor
- Python bağımlılıklarını yükleyin: `pip install -r requirements.txt`
- Portların kullanımda olmadığını kontrol edin
- Health check yapın: `http://localhost:5000/health`

## 🚀 Build & Release

### Android APK
\`\`\`bash
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
\`\`\`

### Android App Bundle (Google Play)
\`\`\`bash
flutter build appbundle --release
# AAB: build/app/outputs/bundle/release/app-release.aab
\`\`\`

### iOS
\`\`\`bash
flutter build ios --release
# Xcode ile Archive → Distribute
\`\`\`

## 📝 Notlar

- **Ağ Bağlantısı**: Backend servisleri aynı ağda olmalı
- **Performans**: İlk çeviri biraz yavaş olabilir (model yüklemesi)
- **Ses Kalitesi**: Sessiz ortamda daha iyi sonuç alınır
- **Pil Tüketimi**: Sürekli dinleme modu pil tüketir

## 🛡️ Güvenlik

- Üretim ortamında HTTPS kullanın
- API anahtarlarını environment variables'da saklayın
- Rate limiting ekleyin
- Kullanıcı kimlik doğrulaması ekleyin

## 📄 Lisans

MIT License

## 👨‍💻 Geliştirici

Bu proje, mevcut web uygulamasının Flutter mobil versiyonudur. Tüm özellikler ve işlevsellik korunmuştur.

## 🙏 Teşekkürler

- Flutter Team
- Google Translate API
- Whisper AI (OpenAI)
- Web Speech API
- gTTS (Google Text-to-Speech)

---

**Not**: Backend servislerinin çalışır durumda olması gereklidir. Detaylı backend kurulumu için ana README.MD dosyasına bakınız.
