import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart'; // Tema yolunu güncelleyin

// Yeni ayırdığımız widget'ları import ediyoruz
import 'widgets/message_list.dart';
import 'widgets/message_input_bar.dart';
import 'widgets/announcement_banner.dart';
import 'widgets/emoji_picker.dart';

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

  // Emoji listesi burada kalabilir, çünkü state'in bir parçası
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
    ':-[': 'assets:emojis/vampire.png',
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

  // --- Veri Çekme ve Gönderme Fonksiyonları ---
  // (Bunlar state'e ait olduğu için burada kalmalı)

  Future<void> _fetchUsername() async {
    final uid = user?.uid;
    if (uid == null) return;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
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

  void _openEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBeigeBackground,
      builder: (context) {
        // Artık public EmojiPicker widget'ını kullanıyoruz
        return EmojiPicker(
          emojis: oldschoolEmojis,
          onEmojiSelected: (key) {
            _messageController.text += ' $key';
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bool isAnnouncementRoom = widget.roomName == 'Duyuru Odası';
    final bool isAdmin = userRole == 'admin';

    if (isAnnouncementRoom && !isAdmin) {
      // Artık public AnnouncementBanner widget'ını kullanıyoruz
      return const AnnouncementBanner();
    } else {
      // Artık public MessageInputBar widget'ını kullanıyoruz
      return MessageInputBar(
        controller: _messageController,
        onSendPressed: _sendMessage,
        onEmojiPressed: _openEmojiPicker,
      );
    }
  }

  // --- ANA BUILD METODU ---
  // Artık çok daha temiz!
  @override
  Widget build(BuildContext context) {
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
            // Artık public MessageList widget'ını kullanıyoruz
            child: MessageList(
              roomId: widget.roomId,
              currentUserId: user?.uid,
              oldschoolEmojis: oldschoolEmojis,
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }
}