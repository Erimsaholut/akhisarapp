import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart'; // Tema import yolunu güncelleyin

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onEmojiPressed;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onEmojiPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined,
                color: kOliveGreenPrimary),
            onPressed: onEmojiPressed,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Mesaj yaz...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kOliveGreenPrimary, width: 2),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: kOliveGreenPrimary),
            onPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}