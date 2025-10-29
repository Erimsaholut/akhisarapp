import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart'; // tema renklerini ekledik

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;

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
    final existing =
    await usersRef.where('username', isEqualTo: newUsername).get();
    if (existing.docs.isNotEmpty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu kullanıcı adı zaten kullanılıyor'),
          backgroundColor: kTerracottaAccent,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await usersRef.doc(uid).update({'username': newUsername});

    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı güncellendi'),
          backgroundColor: kOliveGreenPrimary,
        ),
      );
      Navigator.pop(context);
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
        child: Column(
          children: [
            const Text(
              'Kullanıcı Adı Değiştir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              cursorColor: kOliveGreenPrimary,
              decoration: InputDecoration(
                labelText: 'Yeni Kullanıcı Adı',
                labelStyle: const TextStyle(color: kDarkText),
                filled: true,
                fillColor: kCardSurface,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: kSageGreenSecondary.withOpacity(0.6)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                  BorderSide(color: kOliveGreenPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator(color: kOliveGreenPrimary)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOliveGreenPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _updateUsername,
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}