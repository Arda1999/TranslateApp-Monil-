import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android bildirim kanalını oluştur
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'connection_requests',
      'Bağlantı İstekleri',
      description: 'Kullanıcılardan gelen bağlantı istekleri',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Android ayarları
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Bildirime tıklandığında yapılacak işlemler
        print('📱 Bildirime tıklandı: ${response.payload}');
      },
    );

    // İzin isteme (Android 13+ için)
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      print('📱 Bildirim izni: $granted');
    }

    // İzin isteme (iOS için)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _isInitialized = true;
    print('✅ Bildirim servisi başlatıldı');
  }

  Future<void> showConnectionRequest(String fromUserName) async {
    print('📬 Bildirim gösteriliyor: $fromUserName');
    
    // Telefonu titret
    await _vibrate();

    // Bildirim göster
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'connection_requests',
      'Bağlantı İstekleri',
      channelDescription: 'Kullanıcılardan gelen bağlantı istekleri',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Bağlantı İsteği',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      category: AndroidNotificationCategory.call,
      styleInformation: BigTextStyleInformation(
        '$fromUserName sizinle bağlantı kurmak istiyor',
        htmlFormatBigText: true,
        contentTitle: 'Bağlantı İsteği 📞',
        htmlFormatContentTitle: true,
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        0, // Bildirim ID
        'Bağlantı İsteği 📞',
        '$fromUserName sizinle bağlantı kurmak istiyor',
        notificationDetails,
        payload: fromUserName,
      );
      print('✅ Bildirim başarıyla gönderildi: $fromUserName');
    } catch (e) {
      print('❌ Bildirim gösterme hatası: $e');
    }
  }

  Future<void> _vibrate() async {
    try {
      // Cihazın titreşimi destekleyip desteklemediğini kontrol et
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 1 saniye titre, 500ms bekle, 1 saniye titre
        await Vibration.vibrate(
          pattern: [0, 1000, 500, 1000],
          intensities: [0, 128, 0, 255],
        );
        print('📳 Telefon titreşti');
      }
    } catch (e) {
      print('⚠️ Titreşim hatası: $e');
    }
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void dispose() {
    // Cleanup işlemleri
  }
}
