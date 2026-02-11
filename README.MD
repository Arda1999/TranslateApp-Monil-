# 📱 Flutter Mobil Çeviri Uygulaması

Bu proje Flutter ile geliştirilmiş karşılıklı konuşma ve çeviri mobil uygulamasıdır.

**⚠️ NOT:** Backend servisleri bu projede değil, ana web projesinde (`C:\Users\apeker\Desktop\Code\TranslatorApp`) bulunmaktadır.

## 🚀 Hızlı Başlangıç

### 1️⃣ Backend Servislerini Başlat (Web Projesinden)

```bash
# Ana web projesine git
cd C:\Users\apeker\Desktop\Code\TranslatorApp\SpeechToTextToTranslate

# Backend servislerini başlat
npm run dev
```

Bu komut aşağıdaki servisleri başlatır:
- WebSocket Sunucusu (port 8080)
- Flask Detect Language (port 5000)  
- Flask Text-to-Speech (port 5002)

### 2️⃣ Flutter Mobil Uygulamayı Çalıştır

```bash
# Flutter projesine git
cd flutter_translator_app

# Bağımlılıkları yükle (ilk seferde)
flutter pub get

# Android Emulator'de çalıştır
flutter run -d emulator-5554

# Fiziksel cihazda çalıştır
flutter run
```

## ⚙️ IP Yapılandırması

Backend servislerini başlattığınızda terminal'de Network IP adresinizi göreceksiniz:
```
➜  Network: http://172.20.10.4:5000/
➜  Network: http://172.20.10.4:5002/
```

Flutter app'i başlattıktan sonra **Settings ekranından IP'yi ayarlayın:**

### **🔧 Hangi IP'yi Kullanmalıyım?**

**📱 Fiziksel Android/iOS Telefon:**
- Backend başlatıldığında gördüğünüz Network IP'yi kullanın
- Örnek: `172.20.10.4` (sizinki farklı olabilir)
- ⚠️ Telefon ve PC **aynı Wi-Fi ağında** olmalı!

**💻 Android Emulator:**
- IP: `10.0.2.2` 
- (Emulator'ün host PC'ye özel erişim IP'si)

**🌐 iOS Simulator:**
- Backend başlatıldığında gördüğünüz Network IP
- Veya `localhost` (simulator host ile aynı ağda)

### **📡 IP Adresinizi Bulma:**

**Windows:**
```bash
ipconfig
# "Wireless LAN adapter Wi-Fi" altında "IPv4 Address" bakın
```

**Mac/Linux:**
```bash
ifconfig | grep "inet "
# veya
ip addr show
```

### **✅ Bağlantıyı Test Etme:**

1. Settings → IP'yi gir ve "Kaydet ve Yeniden Bağlan"
2. "Servis Durumu" bölümünde tüm servisler **yeşil** olmalı
3. Eğer kırmızı ise:
   - IP doğru mu kontrol edin
   - PC firewall'u kapalı mı kontrol edin
   - Aynı ağda mısınız kontrol edin

## 🧪 Test Senaryoları

### **Gerçek Cihaz Olmadan Test Etme:**

**Yöntem 1: İki Emulator (Önerilen)**
```bash
# Terminal 1: İlk emulator'ü başlat
flutter emulators --launch Pixel_3a_API_30_x86

# Terminal 2: İkinci emulator'ü başlat
flutter emulators --launch Pixel_5_API_31_x86

# Terminal 3: İlk emulator'e app yükle
flutter run -d emulator-5554

# Terminal 4: İkinci emulator'e app yükle
flutter run -d emulator-5556
```


**Yöntem 2: Emulator + Web**
```bash
# Terminal 1: Emulator'de çalıştır
flutter run -d emulator-5554 veya ikinici emulatörü aç aşağıda device managere bas create android emulator de fe oradan yeni emulator oluşcak flutter run -d emulator-5556 gibi mesela sonra

flutter run -d emulator-5556
yaz ve onda da çalışsın.

# Terminal 2: Web'de çalıştır
flutter run -d chrome
```

**Yöntem 3: Web + Orijinal Web App**
```bash
# Terminal 1: Flutter Web
cd flutter_translator_app
flutter run -d chrome

# Terminal 2: Orijinal Web App
cd SpeechToTextToTranslate
npm run dev
```

### **Test Adımları:**

1. **Backend'i başlat:** `npm run start:all`
2. **İki cihaz/emulator başlat** (yukarıdaki yöntemlerden biri)
3. **Her iki cihazda:**
   - Settings → IP'yi ayarla (`10.0.2.2` emulator için)
   - "Servisleri Test Et" → Tüm servisler yeşil olmalı
   - Connection → Karşı kullanıcıyı gör
4. **Birinci cihazdan:** İkinci cihaza bağlantı isteği gönder
5. **İkinci cihazdan:** Bağlantı isteğini kabul et
6. **İki moddan birini seç:**
   - **Start Recording:** Ses kaydeder → Gönderir → Karşı taraf duyar
   - **Start Speaking:** Canlı konuşma tanıma → Çeviri → Seslendirme

### **Android Emulator'de Mikrofon Simülasyonu:**

Android Emulator'de gerçek mikrofon kullanabilirsiniz:

**Yöntem 1: PC Mikrofonunu Kullanma (Önerilen)**
1. Emulator'ü başlattığınızda, Emulator penceresinin sağ tarafındaki **"..." (Extended Controls)** butonuna basın
2. **Microphone** sekmesine gidin
3. **"Virtual microphone uses host audio input"** seçeneğini aktif edin
4. PC'nizin mikrofonuna konuşun, emulator mikrofon girdisi olarak kullanacak

**Yöntem 2: Ses Dosyası Playback**
1. Extended Controls → **Microphone**
2. **"Virtual microphone uses WAV file"** seçin
3. Hazırladığınız WAV dosyasını seçin
4. Play butonuna basın

**Yöntem 3: Emulator Komut Satırı**
```bash
# Emulator başlatırken mikrofon desteğini açık tutun
emulator -avd <avd_name> -qemu -soundhw all
```

**Test Senaryosu:**
1. **Emulator 1:** Start Speaking → PC mikrofonuna "Hello world" de
2. **Emulator 2:** Çevirilen sesi duymalı ("Merhaba dünya")
3. Konuşma tanıma çalışmazsa: Settings → Permissions → Microphone izni verin

**Not:** Android emulator'de ses kaydı bazen yavaş çalışabilir. Gerçek cihazda daha iyi performans alırsınız.

---
- [Flutter README](flutter_translator_app/README.md)
- [Hızlı Başlangıç](flutter_translator_app/QUICKSTART.md)
- [Yapılandırma](flutter_translator_app/CONFIGURATION.md)
- [IP Yapılandırması](flutter_translator_app/IP_CONFIGURATION.md)

**Özellikler:**
- ✅ Tüm web özellikleri mobilde çalışıyor
- ✅ WebSocket bağlantısı
- ✅ Ses kaydetme ve gönderme
- ✅ Gerçek zamanlı konuşma tanıma
- ✅ Otomatik dil algılama
- ✅ Text-to-Speech
- ✅ Modern Material Design UI
- ✅ Kalıcı IP kaydetme (SharedPreferences)

---

2.
    1)venv\Scripts\activate
    2)C:\Users\apeker\Desktop\Code\TranslatorApp\FlaskTextToSpeech\python app.py

3.
    1)venv\Scripts\activate
    2)C:\Users\apeker\Desktop\Code\TranslatorApp\FlaskSpeakerDiarize\python app.py

4.
    1)venv\Scripts\activate
    2)C:\Users\apeker\Desktop\Code\TranslatorApp\FlaskDetectLanguage>python app.py

5.
    1)C:\Users\apeker\Desktop\Code\TranslatorApp\ConnectTsApp\ npm i
    2)C:\Users\apeker\Desktop\Code\TranslatorApp\ConnectTsApp\  npm start


    !!!!!!!!CHANCE MİC projesi ni kullanmama nedenimiz SpeechTotextTranslate projesinde bu işlemi yapıyoruz.

    Yukarıda da bahsettim!!!!!!


VEYA HEPSİNİ TEK KOMUTTA ÇALIŞTIRMAK İSTERSEK, start-all.js KODUNU ÇALIŞTIR.

==> npm run start:all

---

## 🎙️ UYGULAMANIN ÇALIŞMA MANTIĞI

### **1. "Start Recording" Butonuna Basıldığında:**

**Adım 1: Ses Kaydı (5 saniye)**
- Mikrofondan 5 saniye boyunca ses kaydı alınır
- Ses MP3 formatında kaydedilir
- Bu süre zarfında konuşmanız dinlenir

**Adım 2: Mikrofon Değiştirilir**
- `changeMicrophone(3)` komutuyla mikrofon index **3**'e geçilir
- Port 3005'teki serverChangeMic.cjs üzerinden PowerShell komutu çalıştırılır

**Adım 3: Dil Tespiti**
- Kaydedilen 5 saniyelik ses dosyası Flask API'ye gönderilir (Port 5000)
- FlaskDetectLanguage servisi hangi dilde konuştuğunuzu tespit eder
- Örneğin: "tr: Turkish", "en: English", "de: German" vs.
- Otomatik olarak dil seçilir (languageSelect dropdown)

**Adım 4: Konuşma Tanıma Başlatılır**
- Web Speech API devreye girer (`recognition1.start()`)
- Sürekli dinleme modu aktif olur (`continuous: true`)
- Her kelime anlık olarak metne çevrilir
- Sonuçlar `result` div'inde gösterilir

**Adım 5: Otomatik Çeviri**
- Tanınan metin otomatik olarak çevrilir
- Türkçe ↔ İngilizce veya diğer diller arası çeviri
- Çevrilen metin `translatedResult` div'inde gösterilir
- Google Translate Free API kullanılır

---

### **2. "Start Speaking" Butonuna Basıldığında:**

Aynı işlemler gerçekleşir, ancak **farklı mikrofon** kullanılır:

```
startRecording()          → 5 sn ses kaydı + dil tespiti
listMicrophones()         → Mevcut mikrofonları listele
changeMicrophone(2)       → Mikrofon index 2'ye geç
recognition1.start()      → Konuşma tanımayı başlat
```

**Fark:** 

- "Get-AudioDevice -List" Komutu ile mevcut mikrofonlar listelenir.

- Eğer manuel mikrofon değiştirmek istersek;

        Set-AudioDevice -Index 3

        veya

        Set-AudioDevice -Index 2 

------------------------------------------------------------------------

- `Start Recording` → Mikrofon **3** kullanır ==> Sistemde çalan sesleri yakalar ( Stereo Mix (Realtek(R) Audio))

Start Recording (Yerel Test):
[Butona bas] 
  ↓
textToSpeechEnabled = false ⛔
  ↓
Mikrofon 3 (Stereo Mix)
  ↓
Konuşma tanıma çalışır ✅
  ↓
Çeviri yapılır ✅
  ↓
Seslendirme YAPILMAZ 🔇 (karışma yok!)
------------------------------------------------------------------------

- `Start Speaking` → Mikrofon **2** kullanır ==> Laptop’un dahili mikrofonu yani konuşmaları yakalar. (Microphone Array (Intel® Smart Sound Technology for Digital Microphones))

Start Speaking (WebSocket Modu):
[Butona bas]
  ↓
textToSpeechEnabled = true ✅
  ↓
Mikrofon 2 (Laptop Mic)
  ↓
Konuşma tanıma + Çeviri
  ↓
Seslendirme YAPILIR 🔊
  ↓
WebSocket ile karşı tarafa gönderilir 📡

Bu sayede farklı mikrofon girişleri arasında geçiş yapabilirsiniz.

------------------------------------------------------------------------

### **3. "Stop Recording" Butonuna Basıldığında:**

- Konuşma tanıma durdurulur (`recognition1.stop()`)
- Kayıt durumu sıfırlanır
- Butonlar tekrar aktif hale gelir

---

## 📊 UYGULAMANIN GENEL AKIŞI

```
[Butona Bas] 
    ↓
[5 saniye ses kaydı al]
    ↓
[Flask API'ye gönder → Dil Tespit Et (Port 5000)]
    ↓
[Dili otomatik seç]
    ↓
[Web Speech API başlat]
    ↓
[Konuş → Metin oluştur → Çevir → Göster]
    ↓
[Sürekli dinle (continuous mode)]
```

---

## 🔧 KULLANILAN SERVİSLER VE PORTLAR:

1. **Ana Uygulama (Port 3000):** Vite + React - Kullanıcı arayüzü
2. **Mikrofon Değiştirme (Port 3005):** serverChangeMic.cjs - PowerShell komutlarıyla mikrofon kontrolü
3. **Dil Tespiti (Port 5000):** FlaskDetectLanguage - Ses dosyasından dil tespiti
4. **Text-to-Speech (Port 5002):** FlaskTextToSpeech - Metni sese çevirme
5. **Speaker Diarization (Port 5001):** FlaskSpeakerDiarize - Konuşmacı ayrıştırma
6. **WebSocket Sunucusu (Port 8080):** ConnectTsApp - Kullanıcılar arası bağlantı

---

## 🎯 ÖZELLİKLER:

- ✅ Otomatik dil tespiti (ilk 5 saniyede)
- ✅ Gerçek zamanlı konuşma tanıma
- ✅ Anlık çeviri (çok dilli destek)
- ✅ Çoklu mikrofon desteği
- ✅ Konuşmacı ayrıştırma (diarization)
- ✅ Text-to-Speech dönüşüm
- ✅ WebSocket ile çok kullanıcılı iletişim

---

## 🌐 AYNI WiFi AĞINDAN BAŞKA CİHAZDAN BAĞLANMA

### **Sunucu Bilgisayarda (192.168.68.64):**

1. Tüm servisleri çalıştır:
   ```bash
   npm run start:all
   ```

2. Windows Güvenlik Duvarı ayarları:
   - **Windows Güvenlik** → **Güvenlik Duvarı ve ağ koruması** → **Gelişmiş ayarlar**
   - **Gelen Kurallar** → **Yeni Kural** → **Bağlantı noktası**
   - **TCP** seç ve şu portları ekle: `3000, 8080, 5002, 5000, 3005`
   - **Bağlantıya izin ver** → İsim ver: "TranslatorApp"

### **Diğer Cihazdan:**

Tarayıcıda şu adrese git:
```
http://192.168.68.64:3000
```

**NOT:** Tüm servisler (WebSocket, TTS, Detect Language, Mic Change) sunucu bilgisayarda çalışmalı. Diğer cihazda sadece tarayıcı yeterli.

---

## ⚠️ ÖNEMLİ: MİKROFON SEÇİMİ HAKKINDA

### **Sunucu Bilgisayarda (192.168.68.64):**
- Mikrofon değiştirme **çalışır** (PowerShell + AudioDeviceCmdlets)
- Start Recording → Mikrofon 3 (Stereo Mix - sistem sesleri)
- Start Speaking → Mikrofon 2 (Microphone Array - fiziksel mikrofon)

### **Mobil/Tablet/Diğer Bilgisayarlarda:**
- Mikrofon değiştirme servisi **erişilemez** (192.168.68.64:3005 çalışmaz)
- Uygulama **hata vermeden devam eder**
- **Varsayılan mikrofon** kullanılır (cihazın ana mikrofonu)
- Stereo Mix konsepti mobilde yoktur
- Her iki buton da (Start Recording/Speaking) aynı mikrofonu kullanır

**Çözüm:** 
- Remote cihazlardan sadece **Start Speaking** kullanın
- Mikrofon değiştirme uyarısı göz ardı edilebilir
- Mobil cihazlar default mikrofonla sorunsuz çalışır

---
