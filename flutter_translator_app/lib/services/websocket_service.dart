import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  String? _userId;
  String? _connectedUserId;
  final String host;
  
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _userListController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<List<Map<String, dynamic>>> get userListStream =>
      _userListController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  String? get userId => _userId;
  String? get connectedUserId => _connectedUserId;
  bool get isConnected => _channel != null;

  WebSocketService({required this.host});

  Future<void> connect() async {
    try {
      print('🔌 WebSocket bağlanıyor: ws://$host:8080');
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$host:8080'),
      );

      _connectionStatusController.add(true);
      print('✅ WebSocket bağlantısı kuruldu');

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket hatası: $error');
          _connectionStatusController.add(false);
        },
        onDone: () {
          print('⚠️ WebSocket bağlantısı kapandı');
          _connectionStatusController.add(false);
          _channel = null;
        },
      );
    } catch (e) {
      print('❌ WebSocket bağlantı hatası: $e');
      _connectionStatusController.add(false);
    }
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final message = json.decode(rawMessage);
      print('📨 Mesaj alındı: ${message['type']}');

      switch (message['type']) {
        case 'user_id':
          _userId = message['userId'];
          print('🆔 Kullanıcı ID: $_userId');
          // Cihaz tipini gönder
          sendDeviceInfo();
          _messageController.add(message);
          break;

        case 'user_list':
          final users = List<Map<String, dynamic>>.from(message['users']);
          print('👥 Kullanıcı listesi güncellendi: ${users.length} kullanıcı');
          _userListController.add(users);
          break;

        case 'connect_request':
          print('📞 Bağlantı isteği alındı: ${message['fromUserId']}');
          _messageController.add(message);
          break;

        case 'connect_confirmed':
          _connectedUserId = message['targetUserId'];
          print('✅ Bağlantı kuruldu: $_connectedUserId');
          _messageController.add(message);
          break;

        case 'connect_rejected':
          print('❌ Bağlantı reddedildi: ${message['targetUserId']}');
          _messageController.add(message);
          break;

        case 'audio':
          print('🔊 Ses verisi alındı');
          _messageController.add(message);
          break;

        case 'error':
          print('❌ Hata: ${message['message']}');
          _messageController.add(message);
          break;

        default:
          _messageController.add(message);
      }
    } catch (e) {
      print('❌ Mesaj işleme hatası: $e');
    }
  }

  void sendDeviceInfo({String? userName}) {
    if (_userId == null) return;
    
    String deviceType = '📱 MOBİL';
    if (Platform.isAndroid) {
      deviceType = '📱 MOBİL (Android)';
    } else if (Platform.isIOS) {
      deviceType = '📱 MOBİL (iOS)';
    }

    send({
      'type': 'device_info',
      'userId': _userId,
      'deviceType': deviceType,
      'userName': userName ?? 'Misafir',
    });
    print('👤 Kullanıcı bilgisi gönderildi: ${userName ?? "Misafir"}');
  }

  void sendConnectionRequest(String targetUserId) {
    send({
      'type': 'connect_request',
      'targetUserId': targetUserId,
    });
    print('📞 Bağlantı isteği gönderildi: $targetUserId');
  }

  void sendConnectionResponse(String fromUserId, bool accepted) {
    send({
      'type': 'connect_response',
      'fromUserId': fromUserId,
      'accepted': accepted,
    });
    
    if (accepted) {
      _connectedUserId = fromUserId;
      print('✅ Bağlantı kabul edildi: $fromUserId');
    } else {
      print('❌ Bağlantı reddedildi: $fromUserId');
    }
  }

  void sendAudio(String audioBase64, String targetUserId) {
    send({
      'type': 'audio',
      'audioData': audioBase64,
      'targetUserId': targetUserId,
    });
    print('📡 Ses gönderildi: $targetUserId');
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _userId = null;
    _connectedUserId = null;
    _connectionStatusController.add(false);
    print('🔌 WebSocket bağlantısı kesildi');
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _userListController.close();
    _connectionStatusController.close();
  }
}
