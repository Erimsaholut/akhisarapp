import 'package:flutter/material.dart';
import 'add_friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Arkadaşlar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Arkadaşlar'),
              Tab(text: 'İstekler'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FriendsListTab(),
            FriendRequestsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddFriendScreen()),
            );
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Yeni Ekle'),
          backgroundColor: const Color(0xFF666666),
        ),
      ),
    );
  }
}

class FriendsListTab extends StatelessWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Center(child: Text('Giriş yapılmamış'));
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
          return const Center(child: Text('Veri bulunamadı'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final friends = List<String>.from(data['friends'] ?? []);

        if (friends.isEmpty) {
          return const Center(
            child: Text(
              'Henüz hiç arkadaşın yok',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friendUid = friends[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final friendData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final friendName = friendData['username'] ?? 'Bilinmeyen';

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friendName),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Emin misin?'),
                          content: Text('$friendName arkadaşlıktan çıkarılacak. Onaylıyor musun?'),
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

                        // Remove from both users' friend lists
                        await usersRef.doc(currentUid).update({
                          'friends': FieldValue.arrayRemove([friendUid]),
                        });

                        await usersRef.doc(friendUid).update({
                          'friends': FieldValue.arrayRemove([currentUid]),
                        });
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  Future<void> _acceptRequest(String requesterUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final usersRef = FirebaseFirestore.instance.collection('users');

    // Add each other as friends
    await usersRef.doc(currentUid).update({
      'friends': FieldValue.arrayUnion([requesterUid]),
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });

    await usersRef.doc(requesterUid).update({
      'friends': FieldValue.arrayUnion([currentUid]),
      'sentRequests': FieldValue.arrayRemove([currentUid]),
    });
  }

  Future<void> _rejectRequest(String requesterUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final usersRef = FirebaseFirestore.instance.collection('users');

    // Remove from request lists
    await usersRef.doc(currentUid).update({
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });

    await usersRef.doc(requesterUid).update({
      'sentRequests': FieldValue.arrayRemove([currentUid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Center(child: Text('Giriş yapılmamış'));
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
          return const Center(child: Text('Veri bulunamadı'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final friendRequests = List<String>.from(data['friendRequests'] ?? []);

        if (friendRequests.isEmpty) {
          return const Center(
            child: Text(
              'Gelen istek bulunmuyor',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            final requesterUid = friendRequests[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(requesterUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final requesterData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final requesterName = requesterData['username'] ?? 'Bilinmeyen';

                return ListTile(
                  title: Text(requesterName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptRequest(requesterUid),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectRequest(requesterUid),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}