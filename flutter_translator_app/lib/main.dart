import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/translator_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kaydedilmiş IP adresini yükle
  final prefs = await SharedPreferences.getInstance();
  final savedHost = prefs.getString('api_host') ?? '192.168.1.100';
  
  runApp(MyApp(savedHost: savedHost));
}

class MyApp extends StatefulWidget {
  final String savedHost;
  
  const MyApp({super.key, required this.savedHost});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TranslatorProvider _provider;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _provider = TranslatorProvider(host: widget.savedHost);
    
    // Bildirim servisini başlat
    NotificationService().initialize();
    
    // Global connection request listener - hangi sayfada olursa olsun bildirim göster
    _provider.onConnectionRequestReceived = (fromUserId, fromUserName) {
      // Bildirim ve titreşimi tetikle
      NotificationService().showConnectionRequest(fromUserName);
      
      // Dialog göster
      _showConnectionRequestDialog(fromUserId, fromUserName);
    };
  }

  void _showConnectionRequestDialog(String fromUserId, String fromUserName) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.call, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bağlantı İsteği',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$fromUserName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'sizinle bağlantı kurmak istiyor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _provider.respondToConnectionRequest(fromUserId, false);
              Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Reddet', style: TextStyle(color: Colors.red)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _provider.respondToConnectionRequest(fromUserId, true);
              Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.check),
            label: const Text('Kabul Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Real-Time Translator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
