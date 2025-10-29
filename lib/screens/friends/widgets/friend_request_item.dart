import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart'; // Yolunuzu kontrol edin

class FriendRequestItem extends StatelessWidget {
  final String requesterUid;

  const FriendRequestItem({super.key, required this.requesterUid});

  Future<void> _acceptRequest(String requesterUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final usersRef = FirebaseFirestore.instance.collection('users');

    // İsteği kabul et
    await usersRef.doc(currentUid).update({
      'friends': FieldValue.arrayUnion([requesterUid]),
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });

    // Gönderen tarafa ekle
    await usersRef.doc(requesterUid).update({
      'friends': FieldValue.arrayUnion([currentUid]),
      'sentRequests': FieldValue.arrayRemove([currentUid]),
    });
  }

  Future<void> _rejectRequest(String requesterUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final usersRef = FirebaseFirestore.instance.collection('users');

    // İsteği reddet
    await usersRef.doc(currentUid).update({
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });

    // Gönderen taraftan isteği kaldır
    await usersRef.doc(requesterUid).update({
      'sentRequests': FieldValue.arrayRemove([currentUid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
      FirebaseFirestore.instance.collection('users').doc(requesterUid).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final requesterData =
        userSnapshot.data!.data() as Map<String, dynamic>;
        final requesterName = requesterData['username'] ?? 'Bilinmeyen';

        return Card(
          color: kCardSurface,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title:
            Text(requesterName, style: const TextStyle(color: kDarkText)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: kOliveGreenPrimary),
                  onPressed: () => _acceptRequest(requesterUid),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kTerracottaAccent),
                  onPressed: () => _rejectRequest(requesterUid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}