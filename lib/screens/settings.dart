import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart'; // tema renkleri

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      _usernameController.text = data['username'] ?? '';
      _bioController.text = data['bioText'] ?? '';
      // Eğer bio yoksa boş bırak
      if ((data['bioText'] ?? '').isEmpty) {
        _bioController.text = '';
      }
    }
  }

  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kullanıcı adı girin'),
          backgroundColor: kTerracottaAccent,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final usersRef = FirebaseFirestore.instance.collection('users');
    final existing = await usersRef.where('username', isEqualTo: newUsername).get();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isTakenByOther = existing.docs.any((doc) => doc.id != currentUid);
    if (isTakenByOther) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu kullanıcı adı zaten kullanılıyor'),
          backgroundColor: kTerracottaAccent,
        ),
      );
      return;
    }
    await usersRef.doc(currentUid).update({
      'username': newUsername,
    });
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı güncellendi'),
          backgroundColor: kOliveGreenPrimary,
        ),
      );
    }
  }

  Future<void> _updateBio() async {
    final newBio = _bioController.text.trim();
    setState(() => _loading = true);
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
      'bioText': newBio,
    });
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biyografi güncellendi'),
          backgroundColor: kOliveGreenPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBackground,
      appBar: AppBar(
        backgroundColor: kOliveGreenPrimary,
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Profil Bilgilerini Güncelle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 25),

              // Kullanıcı adı
              TextField(
                controller: _usernameController,
                cursorColor: kOliveGreenPrimary,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  labelStyle: const TextStyle(color: kDarkText),
                  filled: true,
                  fillColor: kCardSurface,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: kSageGreenSecondary.withOpacity(0.6),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: kOliveGreenPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator(color: kOliveGreenPrimary)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOliveGreenPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _updateUsername,
                      child: const Text('Kullanıcı Adını Kaydet'),
                    ),

              const SizedBox(height: 25),

              // Bio (biyografi)
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 140,
                cursorColor: kOliveGreenPrimary,
                decoration: InputDecoration(
                  labelText: 'Biyografi',
                  hintText: 'Kendin hakkında kısa bir şey yaz...',
                  labelStyle: const TextStyle(color: kDarkText),
                  filled: true,
                  fillColor: kCardSurface,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: kSageGreenSecondary.withOpacity(0.6),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: kOliveGreenPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator(color: kOliveGreenPrimary)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOliveGreenPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _updateBio,
                      child: const Text('Biyografiyi Kaydet'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}