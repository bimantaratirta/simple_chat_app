import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  double scrollPosition = 0.0;
  bool isScrolled = false;
  List<Map<String, dynamic>> listChat = [];
  Socket socket = io(
    'ws://localhost:3000',
    OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
  );

  @override
  void initState() {
    scrollController.addListener(scrollListenter);
    connect();
    super.initState();
  }

  void connect() {
    socket.connect();
    socket.on("sendMsgServer", (data) => print("${socket.id!}: $data"));
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void scrollListenter() {
    scrollPosition = scrollController.position.pixels;
    if (scrollPosition > 50) {
      setState(() {
        isScrolled = true;
      });
    } else {
      setState(() {
        isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Chat App"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  reverse: true,
                  controller: scrollController,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  dragStartBehavior: DragStartBehavior.down,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      for (var chat in listChat) ...[
                        if (chat['sender'] != socket.id) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: size.width / 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade200,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        chat['message'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chat['sent_at'],
                                  style: TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: size.width / 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(chat['message']),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chat['sent_at'],
                                  style: TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isScrolled)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: scrollDown,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink.shade100,
                        ),
                        child: Transform.rotate(
                          angle: 1.6,
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    cursorWidth: 1,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 16,
                      ),
                      fillColor: Colors.white,
                      hintText: "Pesan",
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(48),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                        borderRadius: BorderRadius.all(
                          Radius.circular(48),
                        ),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (textEditingController.text != "") {
                      final Map<String, dynamic> chat = {
                        "message": textEditingController.text,
                        "time": DateTime.now().toLocal().toString()
                      };
                      socket.emit("sendMsg", textEditingController.text);
                      scrollDown();
                      textEditingController.clear();
                    }
                  },
                  child: Text("Kirim"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
