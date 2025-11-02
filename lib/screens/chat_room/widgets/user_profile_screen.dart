import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;
  bool _isFriend = false;
  bool _requestSent = false;
  bool _isMe = false;

  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  Future<void> _checkFriendStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (currentUser.uid == widget.userId) {
      setState(() => _isMe = true);
      return;
    }

    final currentDoc = await _usersRef.doc(currentUser.uid).get();
    if (!currentDoc.exists) return;

    final data = currentDoc.data()!;
    final friends = List<String>.from(data['friends'] ?? []);
    final sentRequests = List<String>.from(data['sentRequests'] ?? []);

    setState(() {
      _isFriend = friends.contains(widget.userId);
      _requestSent = sentRequests.contains(widget.userId);
    });
  }

  Future<void> _sendFriendRequest() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await _usersRef.doc(widget.userId).update({
        'friendRequests': FieldValue.arrayUnion([currentUser.uid])
      });

      await _usersRef.doc(currentUser.uid).update({
        'sentRequests': FieldValue.arrayUnion([widget.userId])
      });

      setState(() {
        _isLoading = false;
        _requestSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arkadaşlık isteği gönderildi.'),
          backgroundColor: kOliveGreenPrimary,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary,
        title: const Text(
          'Kullanıcı Profili',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _usersRef.doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kOliveGreenPrimary));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('Kullanıcı bulunamadı',
                    style: TextStyle(fontSize: 18, color: kSageGreenSecondary)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'Bilinmeyen';
          final bioText = data['bioText'] ?? '';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final iconSize = isTablet ? 200.0 : 180.0;
              final usernameFont = isTablet ? 32.0 : 30.0;
              final bioFont = isTablet ? 20.0 : 18.0;
              final sidePadding = isTablet ? 48.0 : 24.0;
              final topPadding = isTablet ? 60.0 : 36.0;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, topPadding, sidePadding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle,
                          size: iconSize, color: kSageGreenSecondary),
                      const SizedBox(height: 25),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: usernameFont,
                          fontWeight: FontWeight.bold,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bioText.isNotEmpty
                            ? bioText
                            : 'Bu kullanıcı henüz bir biyografi eklememiş.',
                        style: TextStyle(fontSize: bioFont, color: kSageGreenSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      if (!_isMe)
                        _isFriend
                            ? const Text('Zaten arkadaşsınız.',
                            style: TextStyle(color: kDarkText))
                            : _requestSent
                            ? const Text('İstek gönderildi.',
                            style: TextStyle(color: kSageGreenSecondary))
                            : ElevatedButton.icon(
                          onPressed: _isLoading ? null : _sendFriendRequest,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Arkadaş Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOliveGreenPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 30),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}