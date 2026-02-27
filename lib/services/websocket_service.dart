import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:3000'), // Use your backend URL
    );
  }

  Stream get stream => _channel.stream;

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void disconnect() {
    _channel.sink.close();
  }
}