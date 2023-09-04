import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final channel = IOWebSocketChannel.connect('wss://sockets.stg.ojyuken-support.com/app/CXJk25jXbbDU1yLqb7NLKRwIUMADNXH5');
  final streamController = StreamController<String>.broadcast();
  late Timer pingTimer;

  @override
  void initState() {
    super.initState();

    channel.stream.listen((data) {
      streamController.sink.add(data);
    }, onDone: () {
      streamController.close();
    });

    // Send a Pusher subscription message to the server
    final subscriptionMessage = {
      "event": "pusher:subscribe",
      "data": {
        "auth": "",
        "channel": "juken_app"
      }
    };
    channel.sink.add(jsonEncode(subscriptionMessage));

    // Schedule a ping message every 30 seconds
    pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final pingMessage = {
        "event": "pusher:ping",
        "data": {}
      };
      channel.sink.add(jsonEncode(pingMessage));
    });
  }

  @override
  void dispose() {
    channel.sink.close(); // Close the WebSocket connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Example'),
      ),
      body: StreamBuilder(
        stream: streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return Center(
                child: Text(snapshot.data.toString()),
              );
            } else {
              return Center(
                child: Text('No data received.'),
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text('Connection error'),
            );
          }
        },
      ),
    );
  }
}
