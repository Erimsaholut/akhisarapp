import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import 'emoji_picker.dart'; // 1. EmojiPicker'ı import edin

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMine;
  // 2. 'oldschoolEmojis' parametresini buradan kaldırın
  // final Map<String, String> oldschoolEmojis;

  const MessageBubble({
    super.key,
    required this.data,
    required this.isMine,
    // 3. Constructor'dan da kaldırın
    // required this.oldschoolEmojis,
  });

  Widget _buildMessageText(String text) {
    final parts = text.split(' ');
    return Wrap(
      alignment: isMine ? WrapAlignment.end : WrapAlignment.start,
      children: parts.map((part) {
        // 4. Doğrudan 'EmojiPicker.oldschoolEmojis' üzerinden erişin
        if (EmojiPicker.oldschoolEmojis.containsKey(part)) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Image.asset(EmojiPicker.oldschoolEmojis[part]!, width: 20, height: 20),
          );
        } else {
          return Text(
            '$part ',
            style: TextStyle(
              color: isMine ? Colors.white : kDarkText,
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (build metodunun geri kalanı aynı)
    final senderRole = data['senderRole'] ?? 'user';

    Color usernameColor;
    if (senderRole == 'admin') {
      usernameColor = kTerracottaAccent;
    } else if (isMine) {
      usernameColor = Colors.white70;
    } else {
      usernameColor = kDarkText;
    }

    final bubbleColor = isMine ? kOliveGreenPrimary : kCardSurface;
    final timestamp = data['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMine ? 12 : 0),
              bottomRight: Radius.circular(isMine ? 0 : 12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                data['senderUsername'] ?? 'Bilinmeyen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: usernameColor,
                ),
              ),
              _buildMessageText(data['text'] ?? ''),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine ? Colors.white70 : kSageGreenSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}