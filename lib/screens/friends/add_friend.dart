import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart'; // Tema dosyanızın yolu (kontrol edin)

// Arama sonucunun durumunu yönetmek için bir enum
enum SearchStatus {
  initial, // Başlangıç durumu
  notFound, // Kullanıcı bulunamadı
  isMe, // Kullanıcı kendini aradı
  alreadyFriends, // Zaten arkadaşlar
  requestAlreadySent, // Kullanıcı zaten istek göndermiş
  theySentRequest, // Karşı taraf zaten istek göndermiş
  requestSuccessfullySent, // İstek başarıyla gönderildi
  canBeAdded // Kullanıcı bulunDdu ve eklenebilir
}

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _usersRef = FirebaseFirestore.instance.collection('users');

  bool _isLoading = false;
  SearchStatus _status = SearchStatus.initial;
  DocumentSnapshot? _searchResultUser; // Bulunan kullanıcının verisi
  DocumentSnapshot? _currentUserData; // Mevcut kullanıcının verisi (listeleri kontrol için)

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }

  // Mevcut kullanıcının arkadaş listelerini çekiyoruz ki
  // "zaten arkadaş" veya "istek gönderilmiş" kontrollerini yapabilelim.
  Future<void> _fetchCurrentUserData() async {
    if (_currentUser == null) return;
    final doc = await _usersRef.doc(_currentUser!.uid).get();
    if (doc.exists) {
      setState(() {
        _currentUserData = doc;
      });
    }
  }

  // Kullanıcı arama fonksiyonu
  Future<void> _searchUser() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty || _currentUserData == null) return;

    setState(() {
      _isLoading = true;
      _status = SearchStatus.initial;
      _searchResultUser = null;
    });

    // Kullanıcı adına göre arama yapıyoruz
    final querySnapshot =
    await _usersRef.where('username', isEqualTo: searchTerm).get();

    if (querySnapshot.docs.isEmpty) {
      // Kullanıcı bulunamadı
      setState(() {
        _status = SearchStatus.notFound;
        _isLoading = false;
      });
      return;
    }

    // Kullanıcı bulundu
    final foundUser = querySnapshot.docs.first;
    final foundUserId = foundUser.id;

    // Mevcut kullanıcının listelerini al
    final myData = _currentUserData!.data() as Map<String, dynamic>;
    final myFriends = List<String>.from(myData['friends'] ?? []);
    final mySentRequests = List<String>.from(myData['sentRequests'] ?? []);
    final myFriendRequests = List<String>.from(myData['friendRequests'] ?? []);

    // Durum kontrolleri
    if (foundUserId == _currentUser!.uid) {
      _status = SearchStatus.isMe;
    } else if (myFriends.contains(foundUserId)) {
      _status = SearchStatus.alreadyFriends;
    } else if (mySentRequests.contains(foundUserId)) {
      _status = SearchStatus.requestAlreadySent;
    } else if (myFriendRequests.contains(foundUserId)) {
      _status = SearchStatus.theySentRequest;
    } else {
      _status = SearchStatus.canBeAdded;
      _searchResultUser = foundUser;
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Arkadaşlık isteği gönderme fonksiyonu
  Future<void> _sendFriendRequest() async {
    if (_searchResultUser == null || _currentUser == null) return;

    final targetUid = _searchResultUser!.id;
    final currentUid = _currentUser!.uid;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Hedef kullanıcının 'friendRequests' listesine bizim ID'mizi ekle
      await _usersRef.doc(targetUid).update({
        'friendRequests': FieldValue.arrayUnion([currentUid])
      });

      // 2. Bizim 'sentRequests' listemize hedef ID'yi ekle
      await _usersRef.doc(currentUid).update({
        'sentRequests': FieldValue.arrayUnion([targetUid])
      });

      // Başarılı
      setState(() {
        _status = SearchStatus.requestSuccessfullySent;
        _searchResultUser = null;
        _isLoading = false;
      });
      // Mevcut kullanıcı verisini de güncelleyelim ki yeni arama doğru çalışsın
      _fetchCurrentUserData();

    } catch (e) {
      // Hata
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        title: const Text('Arkadaş Ekle'),
        backgroundColor: kOliveGreenPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Arama Çubuğu
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Kullanıcı adı ile ara...',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: kOliveGreenPrimary, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: kOliveGreenPrimary),
                  onPressed: _searchUser,
                  iconSize: 30,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Arama Sonucu Alanı
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildSearchResultWidget(),
          ],
        ),
      ),
    );
  }

  // Arama sonucunu duruma göre gösteren yardımcı widget
  Widget _buildSearchResultWidget() {
    final username = _searchResultUser != null
        ? (_searchResultUser!.data() as Map<String, dynamic>)['username'] ??
        'Bilinmeyen'
        : '';

    switch (_status) {
      case SearchStatus.initial:
        return const Text(
          'Bir kullanıcı adı arayın.',
          style: TextStyle(color: kSageGreenSecondary),
        );
      case SearchStatus.notFound:
        return const Text(
          'Kullanıcı bulunamadı.',
          style: TextStyle(color: kTerracottaAccent),
        );
      case SearchStatus.isMe:
        return const Text(
          'Kendinizi arkadaş olarak ekleyemezsiniz.',
          style: TextStyle(color: kDarkText),
        );
      case SearchStatus.alreadyFriends:
        return Text(
          '$username ile zaten arkadaşsınız.',
          style: const TextStyle(color: kDarkText),
        );
      case SearchStatus.requestAlreadySent:
        return Text(
          '$username kullanıcısına zaten istek göndermişsiniz.',
          style: const TextStyle(color: kDarkText),
        );
      case SearchStatus.theySentRequest:
        return Text(
          '$username size zaten bir istek göndermiş. İstekler sekmesini kontrol edin.',
          style: const TextStyle(color: kDarkText),
          textAlign: TextAlign.center,
        );
      case SearchStatus.requestSuccessfullySent:
        return const Text(
          'Arkadaşlık isteği başarıyla gönderildi!',
          style: TextStyle(color: kOliveGreenPrimary),
        );
      case SearchStatus.canBeAdded:
        if (_searchResultUser == null) return const SizedBox.shrink();
        return Card(
          color: kCardSurface,
          child: ListTile(
            leading: const Icon(Icons.person, color: kOliveGreenPrimary),
            title: Text(username, style: const TextStyle(color: kDarkText)),
            trailing: ElevatedButton(
              onPressed: _sendFriendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOliveGreenPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('İstek Gönder'),
            ),
          ),
        );
    }
  }
}