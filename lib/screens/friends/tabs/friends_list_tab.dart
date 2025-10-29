import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart'; // Yolunuzu kontrol edin
import '../widgets/friend_list_item.dart'; // Yeni widget'ı import et

class FriendsListTab extends StatelessWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Center(
        child: Text('Giriş yapılmamış', style: TextStyle(color: kDarkText)),
      );
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: userDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('Veri bulunamadı', style: TextStyle(color: kDarkText)),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final friends = List<String>.from(data['friends'] ?? []);

        if (friends.isEmpty) {
          return const Center(
            child: Text(
              'Henüz hiç arkadaşın yok',
              style: TextStyle(fontSize: 16, color: kSageGreenSecondary),
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friendUid = friends[index];
            // Artık sadece FriendListItem widget'ını çağırıyoruz
            return FriendListItem(friendUid: friendUid);
          },
        );
      },
    );
  }
}