import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messagesStream =>
      _messageController.stream;

  void connect() {
    // Auto detect platform
    final String url;

    if (kIsWeb) {
      // For Flutter Web (Chrome / Brave)
      url = 'ws://localhost:3000';
    } else {
      // For Android Emulator
      url = 'ws://10.0.2.2:3000';

      // 👉 If using physical phone, replace above with:
      // url = 'ws://YOUR_LOCAL_IP:3000';
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          try {
            final decoded = jsonDecode(message);
            _messageController.add(decoded);
          } catch (e) {
            print("JSON Decode Error: $e");
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          _isConnected = false;
        },
        onDone: () {
          print("WebSocket Closed");
          _isConnected = false;
        },
      );
    } catch (e) {
      print("Connection Error: $e");
      _isConnected = false;
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    } else {
      print("WebSocket not connected");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}