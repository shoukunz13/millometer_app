import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel channel;
  late StreamController<String> _streamController;

  WebSocketService(String url)
      : channel = WebSocketChannel.connect(Uri.parse(url)) {
    _streamController = StreamController<String>.broadcast();
    channel.stream.listen((message) {
      _streamController.add(message);
    });
  }

  Stream<String> get stream => _streamController.stream;

  void dispose() {
    channel.sink.close();
    _streamController.close();
  }
}

// Usage example
void main() {
  final webSocketService = WebSocketService('ws://localhost:3004');

  webSocketService.stream.listen((message) {
    final data = jsonDecode(message);
    print('Received data: $data');
    // Handle the received data here
  });

  // Dispose the service when done
  // webSocketService.dispose();
}
