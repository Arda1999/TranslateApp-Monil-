# 🚀 Hızlı Başlangıç Kılavuzu

## 📋 Önkoşullar

1. **Backend Servislerini Başlatın** (Ana proje dizininde)
2. **Flutter SDK'yı kurun** (https://flutter.dev/docs/get-started/install)
3. **Mobil cihaz veya emulator hazırlayın**

## ⚡ Hızlı Kurulum (5 Dakika)

### 1. Backend Servisleri (Tek Komut)
Ana proje dizininde:
\`\`\`bash
npm run start:all
\`\`\`

**VEYA** Manuel olarak:

**Terminal 1 - WebSocket:**
\`\`\`bash
cd ConnectTsApp
npm install
npm start
\`\`\`

**Terminal 2 - Dil Algılama:**
\`\`\`bash
cd FlaskDetectLanguage
python -m venv venv
venv\\Scripts\\activate
pip install -r requirements.txt
python app.py
\`\`\`

**Terminal 3 - Text-to-Speech:**
\`\`\`bash
cd FlaskTextToSpeech  
python -m venv venv
venv\\Scripts\\activate
pip install -r requirements.txt
python app.py
\`\`\`

### 2. Flutter Uygulaması

\`\`\`bash
cd flutter_translator_app
flutter pub get
\`\`\`

### 3. IP Adresinizi Öğrenin

**Windows:**
\`\`\`bash
ipconfig
# IPv4 Address: 192.168.1.100 (örnek)
\`\`\`

**Mac/Linux:**
\`\`\`bash
ifconfig
# inet 192.168.1.100 (örnek)
\`\`\`

### 4. IP'yi Ayarlayın

**lib/main.dart** dosyasında 18. satırı düzenleyin:
\`\`\`dart
host: '192.168.1.100', // Kendi IP adresinizi yazın
\`\`\`

### 5. Çalıştırın!

\`\`\`bash
flutter run
\`\`\`

## 🎮 Kullanım

### İlk Test (Yerel Mod)
1. **Start Recording** → Konuş → Çeviriyi gör

### İki Cihaz Testi
1. İki cihazda uygulamayı aç
2. **Bağlan** → Karşı taraftaki ID'yi seç
3. **Start Speaking** → Karşılıklı konuş ve çevir

## ✅ Kontrol Listesi

- [ ] Backend servisleri çalışıyor (8080, 5000, 5002)
- [ ] IP adresi doğru ayarlandı
- [ ] Flutter paketleri yüklendi (`flutter pub get`)
- [ ] Cihaz/emulator hazır
- [ ] Mikrofon izni verildi

## 🆘 Sorun mu var?

### WebSocket bağlanamıyor
\`\`\`bash
# Terminal'de test edin
curl http://192.168.1.100:8080
\`\`\`

### Flutter hatası
\`\`\`bash
flutter doctor
flutter clean
flutter pub get
\`\`\`

### Mikrofon çalışmıyor
- Ayarlar → İzinler → Mikrofon ✅

---

**🎉 Başarılar! Herhangi bir sorun olursa detaylı README.md dosyasına bakın.**
