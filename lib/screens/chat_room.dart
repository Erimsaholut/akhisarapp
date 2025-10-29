import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart'; // temayı içe aktardık

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String? _username;
  String? userRole;

  final Map<String, String> oldschoolEmojis = {
    ':)': 'assets/emojis/smile.png',
    ':(': 'assets/emojis/sad.png',
    ':P': 'assets/emojis/tongue.png',
    ';)': 'assets/emojis/wink.png',
    ':D': 'assets/emojis/laugh.png',
    ':-O': 'assets/emojis/surprised.png',
    '8-)': 'assets/emojis/cool.png',
    '<3': 'assets/emojis/heart.png',
    '</3': 'assets/emojis/brokenheart.png',
    ':-*': 'assets/emojis/kiss.png',
    ':-x': 'assets/emojis/secret.png',
    '(*)': 'assets/emojis/star.png',
    '(K)': 'assets/emojis/kissmark.png',
    ':@': 'assets/emojis/angry.png',
    ':[': 'assets/emojis/devil.png',
    ':-[': 'assets/emojis/vampire.png',
    ':p': 'assets/emojis/sick.png',
    '(roll)': 'assets/emojis/roll.png',
    '<:o)': 'assets/emojis/party.png',
    '^o)': 'assets/emojis/sarcastic.png',
    ':\'(': 'assets/emojis/cry.png',
  };

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchUserRole();
  }

  Future<void> _fetchUsername() async {
    final uid = user?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && doc.data()!.containsKey('username')) {
      setState(() {
        _username = doc['username'];
      });
    } else {
      setState(() {
        _username = 'Bilinmeyen';
      });
    }
  }

  void _fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('role')) {
      setState(() {
        userRole = doc['role'];
      });
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': user?.uid,
      'senderEmail': user?.email,
      'senderUsername': _username ?? 'Bilinmeyen',
      'senderRole': userRole ?? 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Widget _buildMessageText(String text, bool isMine) {
    final parts = text.split(' ');
    return Wrap(
      alignment: isMine ? WrapAlignment.end : WrapAlignment.start,
      children: parts.map((part) {
        if (oldschoolEmojis.containsKey(part)) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Image.asset(oldschoolEmojis[part]!, width: 20, height: 20),
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

  void _openEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBeigeBackground,
      builder: (context) {
        return GridView.count(
          crossAxisCount: 6,
          children: oldschoolEmojis.entries.map((entry) {
            return IconButton(
              icon: Image.asset(entry.value),
              onPressed: () {
                _messageController.text += ' ${entry.key}';
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnnouncementRoom = widget.roomName == 'Duyuru Odası';
    final bool isAdmin = userRole == 'admin';

    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary,
        title: Text(widget.roomName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(widget.roomId)
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
                  final dateKey =
                  DateFormat('yyyy-MM-dd').format(timestamp.toDate());
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
                        final dateTime = DateTime.parse(date);
                        final formattedDate = DateFormat('MMMM d, yyyy', 'en_US')
                            .format(dateTime);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kSageGreenSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                      currentIndex++;

                      final dayMessages = groupedMessages[date]!;
                      if (index < currentIndex + dayMessages.length) {
                        final messageDoc = dayMessages[index - currentIndex];
                        final data = messageDoc.data() as Map<String, dynamic>;
                        final isMine = data['senderId'] == user?.uid;

                        final senderRole = data['senderRole'] ?? 'user';

                        Color usernameColor;
                        if (senderRole == 'admin') {
                          usernameColor = kTerracottaAccent;
                        } else if (isMine) {
                          usernameColor = Colors.white70;
                        } else {
                          usernameColor = kDarkText;
                        }

                        final bubbleColor = isMine
                            ? kOliveGreenPrimary
                            : kCardSurface;

                        final timestamp = data['timestamp'] as Timestamp?;
                        final timeString = timestamp != null
                            ? DateFormat('HH:mm').format(timestamp.toDate())
                            : '';

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width * 0.75,
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
                                  bottomLeft:
                                  Radius.circular(isMine ? 12 : 0),
                                  bottomRight:
                                  Radius.circular(isMine ? 0 : 12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['senderUsername'] ?? 'Bilinmeyen',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: usernameColor,
                                    ),
                                  ),
                                  _buildMessageText(data['text'] ?? '', isMine),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMine
                                            ? Colors.white70
                                            : kSageGreenSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      currentIndex += dayMessages.length;
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
          if (isAnnouncementRoom && !isAdmin)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Sadece yöneticiler bu odaya mesaj yazabilir.',
                style: TextStyle(color: kSageGreenSecondary),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: kOliveGreenPrimary),
                    onPressed: _openEmojiPicker,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yaz...',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: kOliveGreenPrimary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: kOliveGreenPrimary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}