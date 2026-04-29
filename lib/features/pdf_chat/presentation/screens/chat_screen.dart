import 'package:flutter/material.dart';
import '../controller/pdf_chat_controller.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final PdfChatController controller;

  const ChatScreen({
    super.key,
    required this.controller,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();

  void sendMessage() {
    final question = textController.text.trim();
    if (question.isEmpty) return;

    textController.clear();
    widget.controller.askQuestion(question);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.pdfName ?? 'PDF Chat',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length +
                      (controller.isThinking ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (controller.isThinking &&
                        index == controller.messages.length) {
                      return const ChatBubble(
                        text: 'Thinking...',
                        isUser: false,
                      );
                    }

                    final message = controller.messages[index];

                    return ChatBubble(
                      text: message.text,
                      isUser: message.isUser,
                    );
                  },
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Ask about this PDF...',
                            filled: true,
                            fillColor: const Color(0xfff1f3f8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: IconButton(
                          onPressed:
                              controller.isThinking ? null : sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}