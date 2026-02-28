import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/websocket_service.dart';
import 'firebase_options.dart';
import 'dart:convert';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ChatScreen());
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebSocketService _socketService = WebSocketService();
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [];


@override
void initState() {
  super.initState();

  _socketService.connect();

  _socketService.messagesStream.listen((message) {
    setState(() {
      messages.add(message);
    });
  });
}

  @override
  void dispose() {
    _socketService.disconnect();
    _controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = {
        "sender": "User1",
        "text": _controller.text,
      };

      _socketService.sendMessage(message);
      _controller.clear();
    }
  }

  Widget buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMe = msg["sender"] == "User1";

    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg["text"],
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Two Way WebSocket Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessageBubble(
                    messages[index]);
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: "Enter message"),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}