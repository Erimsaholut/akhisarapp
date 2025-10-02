import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchUsers() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: searchTerm)
          .get();

      final results = querySnapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'username': doc['username'],
        };
      }).toList();

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Kullanıcı arama hatası: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _addFriend(String friendUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;
    if (friendUid == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kendine istek gönderemezsin')),
      );
      return;
    }

    try {
      final userRef = FirebaseFirestore.instance.collection('users');

      // Karşı tarafa istek gönder
      await userRef.doc(friendUid).update({
        'friendRequests': FieldValue.arrayUnion([currentUid]),
      });

      // Kendi gönderilen istek listene ekle
      await userRef.doc(currentUid).update({
        'sentRequests': FieldValue.arrayUnion([friendUid]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arkadaşlık isteği gönderildi')),
      );
    } catch (e) {
      debugPrint('Arkadaşlık isteği gönderme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Arkadaş Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı adıyla ara',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isSearching) const CircularProgressIndicator(),
            if (!_isSearching && _searchResults.isEmpty)
              const Text('Kullanıcı aramak için bir isim girin.'),
            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      title: Text(user['username']),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => _addFriend(user['uid']),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
