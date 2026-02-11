import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/translator_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // IP adresini otomatik algılama (geliştirme için)
  String _getDefaultHost() {
    // Debug modda varsayılan IP
    // Production'da environment variable veya config kullanın
    const String? envHost = String.fromEnvironment('API_HOST');
    if (envHost != null && envHost.isNotEmpty) {
      return envHost;
    }
    
    // Varsayılan: Uygulama içinden değiştirilebilir
    // Kullanıcı Settings ekranından güncelleyebilir
    return '192.168.1.100'; // Sadece ilk başlatma için
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranslatorProvider(
        host: _getDefaultHost(), // Dinamik host
      ),
      child: MaterialApp(
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
