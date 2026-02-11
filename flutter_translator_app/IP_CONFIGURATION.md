# 🔧 IP Adresi Yapılandırma Alternatifleri

## ❓ Neden IP Adresi Gerekli?

Mobil uygulama **backend servislerine** bağlanmalı:
```
Mobil Cihaz → WiFi → Backend Server (192.168.x.x:8080)
```

`localhost` veya `127.0.0.1` **ÇALIŞMAZ** çünkü mobil cihazın kendisini işaret eder!

---

## ✅ Çözüm 1: Ayarlar Ekranından (Mevcut)

**Zaten uygulamada var! ✨**

1. Uygulamayı aç
2. Sağ üst → **⚙️ Ayarlar**
3. **Sunucu IP Adresi** → Kendi IP'nizi yazın
4. **Kaydet ve Yeniden Bağlan**

**Avantaj:** Kodla uğraşmadan değiştirebilirsiniz!

---

## ✅ Çözüm 2: Shared Preferences (Kalıcı Kayıt)

IP adresi **cihazda saklanır**, her seferinde girmene gerek kalmaz:

\`\`\`dart
// pubspec.yaml'a ekle
shared_preferences: ^2.2.2

// Kaydetme
final prefs = await SharedPreferences.getInstance();
await prefs.setString('api_host', '192.168.1.100');

// Okuma
final host = prefs.getString('api_host') ?? '192.168.1.100';
\`\`\`

---

## ✅ Çözüm 3: Otomatik Network Discovery (Gelişmiş)

Backend'i **otomatik bul**:

\`\`\`dart
// pubspec.yaml'a ekle
network_info_plus: ^5.0.0
multicast_dns: ^0.3.2

// Cihazın kendi IP'sini öğren
final wifiIP = await NetworkInfo().getWifiIP(); // 192.168.1.50

// Backend'i aynı subnet'te ara
// 192.168.1.1 - 192.168.1.254 arasında port 8080'i scan et
\`\`\`

---

## ✅ Çözüm 4: QR Code Tarama (En Pratik!)

Backend bir QR kod göstersin, mobil okusun:

**Backend'de (Node.js):**
\`\`\`javascript
const qrcode = require('qrcode');
const ip = require('ip');

const serverUrl = \`http://\${ip.address()}:8080\`;
qrcode.toTerminal(serverUrl); // QR konsola yazdır
\`\`\`

**Mobil'de:**
\`\`\`dart
// pubspec.yaml'a ekle
mobile_scanner: ^5.0.0

// QR okuyup otomatik bağlan
final barcode = await scanner.scan();
final host = Uri.parse(barcode.rawValue!).host;
\`\`\`

---

## ✅ Çözüm 5: Cloud/Ngrok (Internet Üzerinden)

Aynı WiFi'de olmak zorunda kalma:

\`\`\`bash
# Backend'de
ngrok http 8080
# → https://abc123.ngrok.io

# Mobil'de
host: 'abc123.ngrok.io'
\`\`\`

---

## 🎯 Hangi Çözümü Kullanmalısınız?

| Senaryo | Çözüm |
|---------|-------|
| **Hızlı test** | Mevcut ayarlar ekranı |
| **Sürekli kullanım** | SharedPreferences |
| **Çok cihaz** | QR Code |
| **Uzaktan erişim** | Ngrok/Cloud |
| **Kurumsal** | Environment variables + CI/CD |

---

## 💡 Tavsiyem

**ŞU AN İÇİN:** Mevcut sistemde hiçbir değişiklik yapmayın!

✅ Ayarlar ekranı zaten var  
✅ IP kolayca değiştirilebiliyor  
✅ İlk kullanımda bir kez girin, sonra unutun

**İLERİDE:** SharedPreferences eklerseniz, IP cihazda kalır ve her açılışta girmezsiniz.

---

## 🔍 IP Adresinizi Bulma

**Windows:**
\`\`\`cmd
ipconfig | findstr IPv4
\`\`\`

**Mac/Linux:**
\`\`\`bash
ifconfig | grep "inet " | grep -v 127.0.0.1
\`\`\`

**Router Admin Panel:**
\`\`\`
192.168.1.1 → Bağlı Cihazlar → Backend bilgisayarın IP'si
\`\`\`

---

Şu anki sistem **gayet iyi**, hardcoded IP sadece **varsayılan değer** olarak kullanılıyor. Gerçek değeri **Ayarlar** ekranından değiştirebiliyorsunuz! 👍
