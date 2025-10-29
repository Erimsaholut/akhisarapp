import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'date_header.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final String roomId;
  final String? currentUserId;
  final Map<String, String> oldschoolEmojis;

  const MessageList({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.oldschoolEmojis,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];
        Map<String, List<QueryDocumentSnapshot>> groupedMessages = {};

        for (var doc in messages) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['timestamp'] as Timestamp?;
          if (timestamp == null) continue;
          final dateKey = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
          groupedMessages.putIfAbsent(dateKey, () => []).add(doc);
        }

        final sortedDates = groupedMessages.keys.toList()
          ..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          itemCount: sortedDates.fold<int>(
            0,
                (count, date) => count + groupedMessages[date]!.length + 1,
          ),
          itemBuilder: (context, index) {
            int currentIndex = 0;
            for (final date in sortedDates) {
              if (index == currentIndex) {
                return DateHeader(date: date); // Değişti
              }
              currentIndex++;

              final dayMessages = groupedMessages[date]!;
              if (index < currentIndex + dayMessages.length) {
                final messageDoc = dayMessages[index - currentIndex];
                final data = messageDoc.data() as Map<String, dynamic>;
                final isMine = data['senderId'] == currentUserId;

                return MessageBubble( // Değişti
                  data: data,
                  isMine: isMine,
                  oldschoolEmojis: oldschoolEmojis,
                );
              }
              currentIndex += dayMessages.length;
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}