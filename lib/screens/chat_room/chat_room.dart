import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/announcement_banner.dart';
import 'widgets/message_input_bar.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/message_list.dart';
import 'widgets/emoji_picker.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchUserRole();
  }

  // --- Veri Çekme ve Gönderme Fonksiyonları ---

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
        return EmojiPicker(
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
      return const AnnouncementBanner();
    } else {
      return MessageInputBar(
        controller: _messageController,
        onSendPressed: _sendMessage,
        onEmojiPressed: _openEmojiPicker,
      );
    }
  }

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
            child: MessageList(
              roomId: widget.roomId,
              currentUserId: user?.uid,
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }
}