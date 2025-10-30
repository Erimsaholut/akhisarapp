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

  // 1. Emoji LİSTESİNİ BURADAN SİLDİK
  // Artık 'emoji_picker.dart' dosyası içinde 'static const' olarak duruyor.

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
        // Artık public EmojiPicker widget'ını kullanıyoruz
        return EmojiPicker(
          // 2. 'emojis:' PARAMETRESİNİ BURADAN SİLDİK
          // (Bu, hataya neden oluyordu)
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
      // 3. 'const' ifadesini geri ekledik
      // (Bunun çalışması için announcement_banner.dart dosyasındaki constructor'a 'const' eklediğinizden emin olun)
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
              // 4. 'oldschoolEmojis:' PARAMETRESİNİ BURADAN SİLDİK
              // (Bu, hataya neden oluyordu)
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }
}