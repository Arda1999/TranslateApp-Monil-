import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translator_provider.dart';
import 'connection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // WebSocket bağlantısını başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TranslatorProvider>().connectWebSocket();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        title: Consumer<TranslatorProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Karşılıklı Konuşma ve Çeviri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
             
              ],
            );
          },
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Consumer<TranslatorProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Durum kartı
                  _buildStatusCard(provider),
                  const SizedBox(height: 16),

                  // Bağlantı bilgisi kartı
                  _buildConnectionCard(provider),
                  const SizedBox(height: 16),

                  // Dil seçimi
                  _buildLanguageSelector(provider),
                  const SizedBox(height: 16),

                  // Kontrol butonları
                  _buildControlButtons(provider),
                  const SizedBox(height: 24),

                  // Transkript ve çeviri
                  _buildTranscriptCards(provider),
                  const SizedBox(height: 16),

                  // Geçmiş sonuçlar
                  _buildHistorySection(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(TranslatorProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusIndicator(
              'WebSocket',
              provider.isConnected,
              Icons.cloud,
            ),
            _buildStatusIndicator(
              'Kayıt',
              provider.isRecording,
              Icons.mic,
            ),
            _buildStatusIndicator(
              'Dinleme',
              provider.isListening,
              Icons.hearing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive, IconData icon) {
    return Column(
      children: [
        ScaleTransition(
          scale: isActive ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isActive ? 0.3 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(TranslatorProvider provider) {
    final isConnected = provider.connectedUserId != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isConnected
                ? LinearGradient(
                    colors: [Colors.green.shade400, Colors.teal.shade400],
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isConnected ? Icons.link : Icons.link_off,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          isConnected
              ? 'Bağlı: ${provider.connectedUserName}'
              : 'Bağlantı Yok',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: provider.userId != null
            ? Text('Sizin Adınız: ${provider.userName}')
            : const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Bağlanıyor...'),
                ],
              ),
        trailing: isConnected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bağlantıyı Kes Butonu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Onay dialogu göster
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Bağlantıyı Kes'),
                              ],
                            ),
                            content: Text(
                              '${provider.connectedUserName} ile bağlantıyı kesmek istediğinize emin misiniz?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('İptal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  provider.disconnectFromUser();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Kes'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.link_off,
                          size: 16, color: Colors.white),
                      label: const Text('Kes',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConnectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.people, size: 18, color: Colors.white),
                  label: const Text('Bağlan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
      ),
    );
  }

  Widget _buildLanguageSelector(TranslatorProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.cyan.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Konuşma Dili',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: provider.selectedLanguage,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: const [
                DropdownMenuItem(value: 'tr-TR', child: Text('🇹🇷 Türkçe')),
                DropdownMenuItem(value: 'en-US', child: Text('🇺🇸 English')),
                DropdownMenuItem(value: 'fr-FR', child: Text('🇫🇷 Français')),
                DropdownMenuItem(value: 'de-DE', child: Text('🇩🇪 Deutsch')),
                DropdownMenuItem(value: 'es-ES', child: Text('🇪🇸 Español')),
                DropdownMenuItem(value: 'it-IT', child: Text('🇮🇹 Italiano')),
                DropdownMenuItem(value: 'pt-PT', child: Text('🇵🇹 Português')),
                DropdownMenuItem(value: 'ru-RU', child: Text('🇷🇺 Русский')),
                DropdownMenuItem(value: 'ja-JP', child: Text('🇯🇵 日本語')),
                DropdownMenuItem(value: 'zh-CN', child: Text('🇨🇳 中文')),
                DropdownMenuItem(value: 'ar-SA', child: Text('🇸🇦 العربية')),
                DropdownMenuItem(value: 'ko-KR', child: Text('🇰🇷 한국어')),
                DropdownMenuItem(value: 'hi-IN', child: Text('🇮🇳 हिन्दी')),
              ],
              onChanged: provider.autoDetectLanguage ? null : (value) {
                if (value != null) {
                  provider.setLanguage(value);
                }
              },
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: provider.autoDetectLanguage,
              onChanged: (value) {
                provider.toggleAutoDetectLanguage(value ?? true);
              },
              title: const Text(
                'Otomatik Dil Tespiti (Auto)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                provider.autoDetectLanguage 
                    ? '5 saniye kayıt alıp dil tespit edilir'
                    : 'Seçili dilde direkt konuşma tanıma başlar',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(TranslatorProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade500, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: provider.isListening
                      ? null
                      : () => provider.startRecording(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.fiber_manual_record),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Seslerini Kayıt Et',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade500, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: provider.isListening || provider.connectedUserId == null
                      ? null
                      : () => provider.startSpeaking(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.mic),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Konuşmaya Başla',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade500, Colors.red.shade700],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: provider.isListening
                      ? () => provider.stopRecording()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.stop),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Konuşmayı Durdur',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.amber.shade600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => provider.clearText(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.clear),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Metin Sil',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTranscriptCards(TranslatorProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.teal.shade400],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.record_voice_over,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Konuşma Metni',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Container(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Text(
                      provider.recognizedText.isEmpty
                          ? 'Konuşma henüz başlamadı...'
                          : provider.recognizedText,
                      style: TextStyle(
                        color: provider.recognizedText.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.translate,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Çeviri Metni',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Container(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Text(
                      provider.translatedText.isEmpty
                          ? 'Çeviri bekleniyor...'
                          : provider.translatedText,
                      style: TextStyle(
                        color: provider.translatedText.isEmpty
                            ? Colors.grey
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(TranslatorProvider provider) {
    if (provider.conversationHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Geçmiş Sonuçlar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => provider.clearHistory(),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Temizle'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero, 
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.conversationHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = provider.conversationHistory[index];
                final timestamp = item['timestamp'] as DateTime?;
                final timeStr = timestamp != null 
                    ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
                    : '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (timeStr.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Text(
                      'Orijinal: ${item['original']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Çeviri: ${item['translated']}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
