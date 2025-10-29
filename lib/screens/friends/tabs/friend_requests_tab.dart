import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart'; // Yolunuzu kontrol edin
import '../widgets/friend_request_item.dart'; // Yeni widget'ı import et

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  // Not: _acceptRequest ve _rejectRequest fonksiyonlarını buradan sildik.
  // Onlar artık FriendRequestItem içinde.

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Center(
          child: Text('Giriş yapılmamış',
              style: TextStyle(color: kDarkText)));
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
              child:
              Text('Veri bulunamadı', style: TextStyle(color: kDarkText)));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final friendRequests = List<String>.from(data['friendRequests'] ?? []);

        if (friendRequests.isEmpty) {
          return const Center(
            child: Text(
              'Gelen istek bulunmuyor',
              style: TextStyle(fontSize: 16, color: kSageGreenSecondary),
            ),
          );
        }

        return ListView.builder(
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            final requesterUid = friendRequests[index];
            // Artık sadece FriendRequestItem widget'ını çağırıyoruz
            return FriendRequestItem(requesterUid: requesterUid);
          },
        );
      },
    );
  }
}