import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart'; // Yolunuzu kontrol edin

class FriendListItem extends StatelessWidget {
  final String friendUid;

  const FriendListItem({super.key, required this.friendUid});

  Future<void> _removeFriend(
      BuildContext context, String friendName, String friendUid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardSurface,
        title: const Text('Emin misin?', style: TextStyle(color: kDarkText)),
        content: Text(
          '$friendName arkadaşlıktan çıkarılacak. Onaylıyor musun?',
          style: const TextStyle(color: kDarkText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      final usersRef = FirebaseFirestore.instance.collection('users');

      // Kendinizden arkadaşı kaldırın
      await usersRef.doc(currentUid).update({
        'friends': FieldValue.arrayRemove([friendUid]),
      });

      // Arkadaşınızdan sizi kaldırın
      await usersRef.doc(friendUid).update({
        'friends': FieldValue.arrayRemove([currentUid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
      FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const SizedBox.shrink(); // Veri yoksa boş göster
        }

        final friendData = userSnapshot.data!.data() as Map<String, dynamic>;
        final friendName = friendData['username'] ?? 'Bilinmeyen';

        return Card(
          color: kCardSurface,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.person, color: kOliveGreenPrimary),
            title: Text(friendName, style: const TextStyle(color: kDarkText)),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: kTerracottaAccent),
              onPressed: () => _removeFriend(context, friendName, friendUid),
            ),
          ),
        );
      },
    );
  }
}