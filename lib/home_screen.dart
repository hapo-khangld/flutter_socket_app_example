import 'dart:convert'; // Import thư viện để xử lý JSON
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final channel = IOWebSocketChannel.connect('wss://sockets.stg.ojyuken-support.com/app/CXJk25jXbbDU1yLqb7NLKRwIUMADNXH5');
  String? channelName;
  String eventName = '';
  Map<String, dynamic> eventData = {};

  @override
  void initState() {
    super.initState();
    // Gửi yêu cầu đăng ký vào kênh sau khi kết nối WebSocket
    final request = {
      'event': 'pusher:subscribe',
      'data': {'auth': '', 'channel': 'juken_app'},
    };

    // Chuyển đối tượng JSON thành chuỗi và gửi đi
    channel.sink.add(jsonEncode(request));


    channel.stream.listen((message) {
      // Parse JSON từ chuỗi nhận được
      final Map<String, dynamic> jsonData = jsonDecode(message);

      // Trích xuất channel và event từ JSON
      channelName = jsonData['channel'] as String? ?? ''; // Kiểm tra và gán mặc định là chuỗi rỗng nếu giá trị là null
      eventName = jsonData['event'] as String? ?? '';

      // Kiểm tra xem có phải là sự kiện bạn quan tâm không
      if (channelName == 'juken_app' && eventName == 'comment_today') {
        // Trích xuất dữ liệu từ JSON
        eventData = jsonDecode(jsonData['data'] as String? ?? '{}'); // Kiểm tra và gán mặc định là JSON rỗng nếu giá trị là null

        // Cập nhật giao diện khi nhận được dữ liệu mới
        setState(() {
          print('khang check');
        });
      } else if (channelName == 'juken_app') {
        eventData = jsonDecode(jsonData['data'] as String? ?? '{}'); // Kiểm tra và gán mặc định là JSON rỗng nếu giá trị là null

        // Cập nhật giao diện khi nhận được dữ liệu mới
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (channelName != null) ...[
              Text('Channel: $channelName'),
              Text('Event: $eventName'),
              Text('Data: ${eventData.toString()}'),
            ] else ...[
              const Text('Event: null'),
            ]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
